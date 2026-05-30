const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const http = require('http');
const { URL } = require('url');

let PgPool;
try {
  ({ Pool: PgPool } = require('pg'));
} catch {
  PgPool = null;
}

const PORT = process.env.PORT || 4000;
const USERS_FILE = path.join(__dirname, '..', 'data', 'users.json');
const ACCESS_TTL_HOURS = 12;
const REFRESH_TTL_DAYS = 30;

let users = [];
const memoryAccessSessions = new Map();
const memoryRefreshSessions = new Map();

class SessionStore {
  constructor() {
    this.mode = 'memory';
    this.pool = null;
  }

  async init() {
    const connectionString = process.env.DATABASE_URL;
    if (!connectionString || !PgPool) {
      this.mode = 'memory';
      return;
    }

    this.pool = new PgPool({ connectionString });

    await this.pool.query(`
      CREATE TABLE IF NOT EXISTS auth_sessions (
        token TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        expires_at TIMESTAMPTZ NOT NULL
      );
    `);

    await this.pool.query(`
      CREATE INDEX IF NOT EXISTS idx_auth_sessions_user_id
      ON auth_sessions (user_id);
    `);

    await this.pool.query(`
      CREATE INDEX IF NOT EXISTS idx_auth_sessions_expires_at
      ON auth_sessions (expires_at);
    `);

    await this.pool.query(`
      CREATE TABLE IF NOT EXISTS auth_refresh_tokens (
        token TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        expires_at TIMESTAMPTZ NOT NULL
      );
    `);

    await this.pool.query(`
      CREATE INDEX IF NOT EXISTS idx_auth_refresh_user_id
      ON auth_refresh_tokens (user_id);
    `);

    await this.pool.query(`
      CREATE INDEX IF NOT EXISTS idx_auth_refresh_expires_at
      ON auth_refresh_tokens (expires_at);
    `);

    this.mode = 'postgres';
  }

  async createAccessSession(token, userId, expiresAt) {
    if (this.mode === 'postgres') {
      await this.pool.query(
        'INSERT INTO auth_sessions(token, user_id, expires_at) VALUES ($1, $2, $3)',
        [token, userId, expiresAt.toISOString()]
      );
      return;
    }

    memoryAccessSessions.set(token, { userId, expiresAt: expiresAt.toISOString() });
  }

  async createRefreshSession(token, userId, expiresAt) {
    if (this.mode === 'postgres') {
      await this.pool.query(
        'INSERT INTO auth_refresh_tokens(token, user_id, expires_at) VALUES ($1, $2, $3)',
        [token, userId, expiresAt.toISOString()]
      );
      return;
    }

    memoryRefreshSessions.set(token, { userId, expiresAt: expiresAt.toISOString() });
  }

  async getAccessUserId(token) {
    if (this.mode === 'postgres') {
      const result = await this.pool.query(
        'SELECT user_id FROM auth_sessions WHERE token = $1 AND expires_at > NOW() LIMIT 1',
        [token]
      );
      return result.rows[0]?.user_id || null;
    }

    const session = memoryAccessSessions.get(token);
    if (!session) return null;
    if (new Date(session.expiresAt).getTime() <= Date.now()) {
      memoryAccessSessions.delete(token);
      return null;
    }
    return session.userId;
  }

  async getRefreshUserId(token) {
    if (this.mode === 'postgres') {
      const result = await this.pool.query(
        'SELECT user_id FROM auth_refresh_tokens WHERE token = $1 AND expires_at > NOW() LIMIT 1',
        [token]
      );
      return result.rows[0]?.user_id || null;
    }

    const session = memoryRefreshSessions.get(token);
    if (!session) return null;
    if (new Date(session.expiresAt).getTime() <= Date.now()) {
      memoryRefreshSessions.delete(token);
      return null;
    }
    return session.userId;
  }

  async revokeAccessSession(token) {
    if (!token) return;

    if (this.mode === 'postgres') {
      await this.pool.query('DELETE FROM auth_sessions WHERE token = $1', [token]);
      return;
    }

    memoryAccessSessions.delete(token);
  }

  async revokeRefreshSession(token) {
    if (!token) return;

    if (this.mode === 'postgres') {
      await this.pool.query('DELETE FROM auth_refresh_tokens WHERE token = $1', [token]);
      return;
    }

    memoryRefreshSessions.delete(token);
  }

  async cleanupExpired() {
    if (this.mode === 'postgres') {
      await this.pool.query('DELETE FROM auth_sessions WHERE expires_at <= NOW()');
      await this.pool.query('DELETE FROM auth_refresh_tokens WHERE expires_at <= NOW()');
      return;
    }

    for (const [token, session] of memoryAccessSessions.entries()) {
      if (new Date(session.expiresAt).getTime() <= Date.now()) {
        memoryAccessSessions.delete(token);
      }
    }

    for (const [token, session] of memoryRefreshSessions.entries()) {
      if (new Date(session.expiresAt).getTime() <= Date.now()) {
        memoryRefreshSessions.delete(token);
      }
    }
  }
}

class UserStore {
  constructor(sessionStore) {
    this.sessionStore = sessionStore;
    this.mode = 'json';
    this.users = [];
  }

  async init() {
    if (this.sessionStore.mode === 'postgres') {
      await this.#initPostgres();
      this.mode = 'postgres';
      return;
    }

    this.#loadFromJson();
    this.mode = 'json';
  }

  async #initPostgres() {
    const pool = this.sessionStore.pool;

    await pool.query(`
      CREATE TABLE IF NOT EXISTS auth_users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_auth_users_email
      ON auth_users (email);
    `);

    const countResult = await pool.query('SELECT COUNT(*)::int AS count FROM auth_users');
    const count = countResult.rows[0]?.count ?? 0;
    if (count > 0) return;

    const jsonUsers = this.#loadJsonUsersOnly();
    for (const user of jsonUsers) {
      await pool.query(
        `INSERT INTO auth_users(id, email, password_hash, password_salt, name)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (email) DO NOTHING`,
        [user.id, user.email, user.passwordHash, user.passwordSalt, user.name]
      );
    }
  }

  #ensureUsersFile() {
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
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    if (!fs.existsSync(USERS_FILE)) {
      fs.writeFileSync(USERS_FILE, JSON.stringify(defaultUsers, null, 2), 'utf8');
    }
  }

  #hashPassword(password, salt) {
    return crypto.scryptSync(password, salt, 64).toString('hex');
  }

  #normalizeUser(user) {
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
      const passwordHash = this.#hashPassword(normalized.password, salt);
      normalized.passwordSalt = salt;
      normalized.passwordHash = passwordHash;
      normalized.password = null;
    }

    return normalized;
  }

  #loadJsonUsersOnly() {
    this.#ensureUsersFile();
    const raw = fs.readFileSync(USERS_FILE, 'utf8');
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) throw new Error('users.json must contain an array');
    return parsed.map((item) => this.#normalizeUser(item));
  }

  #loadFromJson() {
    this.users = this.#loadJsonUsersOnly();
    this.#saveJsonUsers();
  }

  #saveJsonUsers() {
    fs.writeFileSync(USERS_FILE, JSON.stringify(this.users, null, 2), 'utf8');
  }

  verifyPassword(user, plainPassword) {
    if (!user.passwordHash || !user.passwordSalt) return false;
    const incomingHash = this.#hashPassword(plainPassword, user.passwordSalt);
    return crypto.timingSafeEqual(Buffer.from(incomingHash, 'hex'), Buffer.from(user.passwordHash, 'hex'));
  }

  async findByEmail(email) {
    if (this.mode === 'postgres') {
      const result = await this.sessionStore.pool.query(
        `SELECT id, email, password_hash AS "passwordHash", password_salt AS "passwordSalt", name
         FROM auth_users
         WHERE email = $1
         LIMIT 1`,
        [email]
      );
      return result.rows[0] || null;
    }

    return this.users.find((item) => item.email === email) || null;
  }

  async findById(id) {
    if (this.mode === 'postgres') {
      const result = await this.sessionStore.pool.query(
        `SELECT id, email, password_hash AS "passwordHash", password_salt AS "passwordSalt", name
         FROM auth_users
         WHERE id = $1
         LIMIT 1`,
        [id]
      );
      return result.rows[0] || null;
    }

    return this.users.find((item) => item.id === id) || null;
  }

  async nextId() {
    if (this.mode === 'postgres') {
      const result = await this.sessionStore.pool.query(
        `SELECT COALESCE(MAX(NULLIF(regexp_replace(id, '[^0-9]', '', 'g'), '')::int), 0) + 1 AS next_num
         FROM auth_users`
      );
      return `u${result.rows[0]?.next_num ?? 1}`;
    }

    return `u${this.users.length + 1}`;
  }

  async createUser({ email, password, name }) {
    const id = await this.nextId();
    const salt = crypto.randomBytes(16).toString('hex');
    const passwordHash = this.#hashPassword(password, salt);

    const user = { id, email, passwordHash, passwordSalt: salt, name };

    if (this.mode === 'postgres') {
      await this.sessionStore.pool.query(
        `INSERT INTO auth_users(id, email, password_hash, password_salt, name)
         VALUES ($1, $2, $3, $4, $5)`,
        [id, email, passwordHash, salt, name]
      );
      return user;
    }

    this.users.push({ ...user, password: null });
    this.#saveJsonUsers();
    return user;
  }
}

const sessionStore = new SessionStore();
const userStore = new UserStore(sessionStore);

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

function extractBearerToken(req) {
  const auth = req.headers.authorization || '';
  if (!auth.startsWith('Bearer ')) return null;
  return auth.slice('Bearer '.length).trim();
}

function userPublic(user) {
  return { id: user.id, email: user.email, name: user.name };
}

async function createAuthPayload(user) {
  const accessToken = crypto.randomBytes(32).toString('hex');
  const refreshToken = crypto.randomBytes(32).toString('hex');

  const accessExpiresAt = new Date(Date.now() + ACCESS_TTL_HOURS * 60 * 60 * 1000);
  const refreshExpiresAt = new Date(Date.now() + REFRESH_TTL_DAYS * 24 * 60 * 60 * 1000);

  await sessionStore.createAccessSession(accessToken, user.id, accessExpiresAt);
  await sessionStore.createRefreshSession(refreshToken, user.id, refreshExpiresAt);

  return {
    token: accessToken,
    refreshToken,
    user: userPublic(user),
  };
}

async function resolveUserFromToken(req) {
  const token = extractBearerToken(req);
  if (!token) return null;

  const userId = await sessionStore.getAccessUserId(token);
  if (!userId) return null;

  return userStore.findById(userId);
}

const server = http.createServer(async (req, res) => {
  if (!req.url || !req.method) return sendJson(res, 400, { error: 'Invalid request' });
  if (req.method === 'OPTIONS') return sendJson(res, 204, {});

  const url = new URL(req.url, `http://localhost:${PORT}`);

  if (req.method === 'GET' && url.pathname === '/health') {
    return sendJson(res, 200, {
      status: 'ok',
      service: 'zappy-backend',
      userStore: userStore.mode,
      sessionStore: sessionStore.mode,
      time: new Date().toISOString(),
    });
  }

  if (req.method === 'POST' && url.pathname === '/api/auth/login') {
    try {
      const body = await readJsonBody(req);
      const email = String(body.email || '').trim().toLowerCase();
      const password = String(body.password || '');
      const user = await userStore.findByEmail(email);

      if (!user || !userStore.verifyPassword(user, password)) {
        return sendJson(res, 401, { error: 'Invalid credentials' });
      }

      return sendJson(res, 200, { data: await createAuthPayload(user) });
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

      const existing = await userStore.findByEmail(email);
      if (existing) return sendJson(res, 409, { error: 'Email already registered' });

      const baseName = nameInput.isNotEmpty ? nameInput : email.split('@')[0].replace(/[._-]+/g, ' ');
      const user = await userStore.createUser({ email, password, name: baseName });

      return sendJson(res, 201, { data: await createAuthPayload(user) });
    } catch (error) {
      return sendJson(res, 400, { error: error.message });
    }
  }

  if (req.method === 'POST' && url.pathname === '/api/auth/refresh') {
    try {
      const body = await readJsonBody(req);
      const refreshToken = String(body.refreshToken || '').trim();
      if (!refreshToken) return sendJson(res, 400, { error: 'Missing refresh token' });

      const userId = await sessionStore.getRefreshUserId(refreshToken);
      if (!userId) return sendJson(res, 401, { error: 'Invalid refresh token' });

      await sessionStore.revokeRefreshSession(refreshToken);

      const user = await userStore.findById(userId);
      if (!user) return sendJson(res, 401, { error: 'Unauthorized' });

      return sendJson(res, 200, { data: await createAuthPayload(user) });
    } catch (error) {
      return sendJson(res, 400, { error: error.message });
    }
  }

  if (req.method === 'POST' && url.pathname === '/api/auth/logout') {
    try {
      const accessToken = extractBearerToken(req);
      const body = await readJsonBody(req);
      const refreshToken = String(body.refreshToken || '').trim();

      if (accessToken) await sessionStore.revokeAccessSession(accessToken);
      if (refreshToken) await sessionStore.revokeRefreshSession(refreshToken);

      return sendJson(res, 200, { data: { success: true } });
    } catch {
      return sendJson(res, 200, { data: { success: true } });
    }
  }

  if (req.method === 'GET' && url.pathname === '/api/auth/me') {
    try {
      const user = await resolveUserFromToken(req);
      if (!user) return sendJson(res, 401, { error: 'Unauthorized' });
      return sendJson(res, 200, { data: userPublic(user) });
    } catch {
      return sendJson(res, 401, { error: 'Unauthorized' });
    }
  }

  if (req.method === 'GET' && url.pathname === '/api/feed') return sendJson(res, 200, { data: feedVideos });
  if (req.method === 'GET' && url.pathname === '/api/chat/threads') return sendJson(res, 200, { data: chatThreads });
  if (req.method === 'GET' && url.pathname === '/api/wallet/summary') return sendJson(res, 200, { data: walletSummary });

  return sendJson(res, 404, { error: 'Route not found' });
});

async function start() {
  try {
    await sessionStore.init();
    await sessionStore.cleanupExpired();
    await userStore.init();
  } catch (error) {
    console.error('Failed to initialize stores:', error.message);
    process.exit(1);
  }

  server.listen(PORT, () => {
    console.log(`Zappy backend running on http://localhost:${PORT}`);
    console.log('Demo login: demo@zappy.app / 123456');
    console.log(`Users file: ${USERS_FILE}`);
    console.log(`User store mode: ${userStore.mode}`);
    console.log(`Session store mode: ${sessionStore.mode}`);
  });
}

start();
