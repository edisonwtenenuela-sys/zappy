const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const http = require('http');
const { URL } = require('url');

const PORT = process.env.PORT || 4000;
const USERS_FILE = path.join(__dirname, '..', 'data', 'users.json');

let users = [];
const activeSessions = new Map();

function ensureUsersFile() {
  const defaultUsers = [
    {
      id: 'u1',
      email: 'demo@zappy.app',
      passwordHash: null,
      passwordSalt: null,
      password: '123456',
      name: 'Demo User'
    }
  ];

  const dir = path.dirname(USERS_FILE);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  if (!fs.existsSync(USERS_FILE)) {
    fs.writeFileSync(USERS_FILE, JSON.stringify(defaultUsers, null, 2), 'utf8');
  }
}

function hashPassword(password, salt) {
  return crypto.scryptSync(password, salt, 64).toString('hex');
}

function normalizeUser(user) {
  const normalized = {
    id: user.id,
    email: String(user.email || '').trim().toLowerCase(),
    name: user.name,
    passwordHash: user.passwordHash ?? null,
    passwordSalt: user.passwordSalt ?? null,
    password: user.password ?? null
  };

  if ((!normalized.passwordHash || !normalized.passwordSalt) && normalized.password) {
    const salt = crypto.randomBytes(16).toString('hex');
    const passwordHash = hashPassword(normalized.password, salt);
    normalized.passwordSalt = salt;
    normalized.passwordHash = passwordHash;
    normalized.password = null;
  }

  return normalized;
}

function loadUsers() {
  ensureUsersFile();
  const raw = fs.readFileSync(USERS_FILE, 'utf8');
  const parsed = JSON.parse(raw);
  if (!Array.isArray(parsed)) {
    throw new Error('users.json must contain an array');
  }

  users = parsed.map(normalizeUser);
  saveUsers();
}

function saveUsers() {
  fs.writeFileSync(USERS_FILE, JSON.stringify(users, null, 2), 'utf8');
}

function verifyPassword(user, plainPassword) {
  if (!user.passwordHash || !user.passwordSalt) {
    return false;
  }
  const incomingHash = hashPassword(plainPassword, user.passwordSalt);
  return crypto.timingSafeEqual(Buffer.from(incomingHash, 'hex'), Buffer.from(user.passwordHash, 'hex'));
}

const feedVideos = Array.from({ length: 8 }, (_, index) => ({
  id: `v${index + 1}`,
  creator: `@creator${index + 1}`,
  description: `Contenido viral #${index + 1} en Zappy`,
  likes: 1200 + index * 137,
  comments: 80 + index * 11,
  shares: 45 + index * 7,
  colorHex: ['#0F172A', '#134E4A', '#155E75', '#1E3A8A', '#312E81', '#4C1D95', '#7C2D12', '#374151'][index % 8]
}));

const chatThreads = [
  {
    id: 't1',
    userName: 'Ana Creator',
    lastMessage: 'Gracias por el regalo de hoy!',
    unreadCount: 2,
    lastAt: new Date(Date.now() - 12 * 60000).toISOString(),
    messages: [
      { id: 'm1', text: 'Hola Ana! tu live estuvo brutal', sentByMe: true, sentAt: new Date(Date.now() - 40 * 60000).toISOString() },
      { id: 'm2', text: 'Gracias por el regalo de hoy!', sentByMe: false, sentAt: new Date(Date.now() - 12 * 60000).toISOString() }
    ]
  },
  {
    id: 't2',
    userName: 'Carlos Gaming',
    lastMessage: 'Mañana hacemos torneo en sala.',
    unreadCount: 0,
    lastAt: new Date(Date.now() - 2 * 3600000).toISOString(),
    messages: [
      { id: 'm3', text: 'Mañana hacemos torneo en sala.', sentByMe: false, sentAt: new Date(Date.now() - 2 * 3600000).toISOString() }
    ]
  }
];

const walletSummary = {
  balanceCoins: 3250,
  estimatedUsd: 32.5,
  packages: [
    { coins: 100, priceUsd: 0.99, isPopular: false },
    { coins: 550, priceUsd: 4.99, isPopular: true },
    { coins: 1200, priceUsd: 9.99, isPopular: false },
    { coins: 2500, priceUsd: 19.99, isPopular: false }
  ],
  gifts: [
    { name: 'Rose', coinCost: 10, emoji: '🌹' },
    { name: 'Fire', coinCost: 50, emoji: '🔥' },
    { name: 'Crown', coinCost: 120, emoji: '👑' },
    { name: 'Rocket', coinCost: 350, emoji: '🚀' }
  ],
  transactions: [
    { title: 'Compra de monedas', dateLabel: 'Hoy, 11:10', amountLabel: '+550 coins', isPositive: true },
    { title: 'Regalo enviado a @AnaCreator', dateLabel: 'Hoy, 10:42', amountLabel: '-120 coins', isPositive: false },
    { title: 'Regalo recibido en live', dateLabel: 'Ayer, 22:15', amountLabel: '+800 coins', isPositive: true },
    { title: 'Solicitud de retiro', dateLabel: 'Ayer, 16:30', amountLabel: '-1,000 coins', isPositive: false }
  ]
};

function sendJson(res, status, body) {
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization'
  });
  res.end(JSON.stringify(body));
}

function readJsonBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (chunk) => {
      data += chunk;
      if (data.length > 1e6) reject(new Error('Payload too large'));
    });
    req.on('end', () => {
      if (!data) return resolve({});
      try {
        resolve(JSON.parse(data));
      } catch {
        reject(new Error('Invalid JSON body'));
      }
    });
    req.on('error', reject);
  });
}

function userPublic(user) {
  return { id: user.id, email: user.email, name: user.name };
}

function createAuthPayload(user) {
  const token = `zappy_token_${user.id}_${Date.now()}`;
  activeSessions.set(token, user.id);
  return { token, user: userPublic(user) };
}

function resolveUserFromToken(req) {
  const auth = req.headers.authorization || '';
  if (!auth.startsWith('Bearer ')) return null;
  const token = auth.slice(7).trim();
  const userId = activeSessions.get(token);
  if (!userId) return null;
  return users.find((u) => u.id === userId) || null;
}

const server = http.createServer(async (req, res) => {
  if (!req.url || !req.method) return sendJson(res, 400, { error: 'Invalid request' });
  if (req.method === 'OPTIONS') return sendJson(res, 204, {});

  const url = new URL(req.url, `http://localhost:${PORT}`);

  if (req.method === 'GET' && url.pathname === '/health') {
    return sendJson(res, 200, { status: 'ok', service: 'zappy-backend', time: new Date().toISOString() });
  }

  if (req.method === 'POST' && url.pathname === '/api/auth/login') {
    try {
      const body = await readJsonBody(req);
      const email = String(body.email || '').trim().toLowerCase();
      const password = String(body.password || '');
      const user = users.find((item) => item.email === email);

      if (!user || !verifyPassword(user, password)) {
        return sendJson(res, 401, { error: 'Invalid credentials' });
      }

      return sendJson(res, 200, { data: createAuthPayload(user) });
    } catch (error) {
      return sendJson(res, 400, { error: error.message });
    }
  }

  if (req.method === 'POST' && url.pathname === '/api/auth/register') {
    try {
      const body = await readJsonBody(req);
      const email = String(body.email || '').trim().toLowerCase();
      const password = String(body.password || '');
      const nameInput = String(body.name || '').trim();

      if (!email.includes('@')) return sendJson(res, 400, { error: 'Invalid email' });
      if (password.length < 6) return sendJson(res, 400, { error: 'Password must be at least 6 characters' });
      if (users.some((item) => item.email === email)) return sendJson(res, 409, { error: 'Email already registered' });

      const baseName = nameInput.isNotEmpty ? nameInput : email.split('@')[0].replace(/[._-]+/g, ' ');
      const salt = crypto.randomBytes(16).toString('hex');
      const passwordHash = hashPassword(password, salt);

      const user = {
        id: `u${users.length + 1}`,
        email,
        passwordHash,
        passwordSalt: salt,
        password: null,
        name: baseName
      };

      users.push(user);
      saveUsers();
      return sendJson(res, 201, { data: createAuthPayload(user) });
    } catch (error) {
      return sendJson(res, 400, { error: error.message });
    }
  }

  if (req.method === 'GET' && url.pathname === '/api/auth/me') {
    const user = resolveUserFromToken(req);
    if (!user) return sendJson(res, 401, { error: 'Unauthorized' });
    return sendJson(res, 200, { data: userPublic(user) });
  }

  if (req.method === 'GET' && url.pathname === '/api/feed') return sendJson(res, 200, { data: feedVideos });
  if (req.method === 'GET' && url.pathname === '/api/chat/threads') return sendJson(res, 200, { data: chatThreads });
  if (req.method === 'GET' && url.pathname === '/api/wallet/summary') return sendJson(res, 200, { data: walletSummary });

  return sendJson(res, 404, { error: 'Route not found' });
});

try {
  loadUsers();
} catch (error) {
  console.error('Failed to load users file:', error.message);
  process.exit(1);
}

server.listen(PORT, () => {
  console.log(`Zappy backend running on http://localhost:${PORT}`);
  console.log('Demo login: demo@zappy.app / 123456');
  console.log(`Users file: ${USERS_FILE}`);
});
