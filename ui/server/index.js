require('dotenv').config({ path: require('path').join(__dirname, '../.env.local') });

const express = require('express');
const http = require('http');
const cors = require('cors');
const { Server } = require('socket.io');

const setupRoutes = require('./routes/setup');
const vaultRoutes = require('./routes/vault');
const metricsRoutes = require('./routes/metrics');
const powerscRoutes = require('./routes/powersc');

const app = express();
const server = http.createServer(app);

const PORT = process.env.API_PORT || 3002;
const NEXT_ORIGIN = `http://localhost:3001`;

// CORS — allow the Next.js frontend on port 3001 and any FQDN access
app.use(
  cors({
    origin: true,
    methods: ['GET', 'POST'],
    credentials: true,
  })
);
app.use(express.json());

// WebSocket for real-time progress updates
const io = new Server(server, {
  cors: { origin: true, methods: ['GET', 'POST'] },
});

io.on('connection', (socket) => {
  console.log(`[ws] client connected: ${socket.id}`);
  socket.on('disconnect', () => console.log(`[ws] client disconnected: ${socket.id}`));
});

// Attach io to req so routes can emit events
app.use((req, _res, next) => {
  req.io = io;
  next();
});

// Routes
app.use('/api/setup', setupRoutes);
app.use('/api/vault', vaultRoutes);
app.use('/api/metrics', metricsRoutes);
app.use('/api/powersc', powerscRoutes);

// Health check
app.get('/health', (_req, res) => res.json({ status: 'ok', port: PORT }));

server.listen(PORT, () => {
  console.log(`[server] API + WebSocket listening on port ${PORT}`);
  console.log(`[server] AIX_HOST: ${process.env.AIX_HOST || '(not set)'}`);
  console.log(`[server] VAULT_ADDR: ${process.env.VAULT_ADDR || 'http://127.0.0.1:8200'}`);
  console.log(`[server] POWERSC_URL: ${process.env.POWERSC_URL || '(not set — scan buttons will show manual instructions)'}`);
});
