const { Client } = require('ssh2');
const fs = require('fs');
const path = require('path');

/**
 * Run a local shell script on a remote host via SSH.
 * Transfers the script, makes it executable, and runs it with optional env vars and sudo.
 *
 * @param {object} opts
 * @param {string} opts.host - Remote hostname or FQDN
 * @param {string} opts.username - SSH username (cecuser)
 * @param {string} opts.privateKeyPath - Absolute path to the .pem SSH key
 * @param {string} opts.localScript - Absolute path to the local script file
 * @param {string} opts.remoteScript - Destination path on the remote host
 * @param {boolean} [opts.sudo] - Whether to prefix the run command with sudo -E
 * @param {object} [opts.env] - Extra environment variables to export before running
 * @param {function} [opts.onOutput] - Called with each line of stdout
 */
function runScriptOnAIX({ host, username, privateKeyPath, localScript, remoteScript, sudo = false, env = {}, onOutput }) {
  return new Promise((resolve, reject) => {
    const conn = new Client();
    let privateKey;

    try {
      privateKey = fs.readFileSync(privateKeyPath);
    } catch (e) {
      return reject(new Error(`Cannot read SSH key at ${privateKeyPath}: ${e.message}`));
    }

    conn.on('ready', () => {
      // Step 1: SCP the script to the remote host
      conn.sftp((err, sftp) => {
        if (err) { conn.end(); return reject(err); }

        const readStream = fs.createReadStream(localScript);
        const writeStream = sftp.createWriteStream(remoteScript);

        writeStream.on('close', () => {
          // Step 2: chmod + run
          const envExports = Object.entries(env)
            .map(([k, v]) => `export ${k}="${v}"`)
            .join('; ');
          const prefix = envExports ? `${envExports}; ` : '';
          const runCmd = `chmod +x ${remoteScript} && ${prefix}${sudo ? 'sudo -E ' : ''}${remoteScript}`;

          conn.exec(runCmd, (err, stream) => {
            if (err) { conn.end(); return reject(err); }

            let buffer = '';
            stream.on('data', (data) => {
              buffer += data.toString();
              const lines = buffer.split('\n');
              buffer = lines.pop(); // keep incomplete last line
              lines.forEach((line) => line.trim() && onOutput?.(line));
            });
            stream.stderr.on('data', (data) => {
              // Log stderr but don't fail — scripts write progress to stderr too
              console.error(`[ssh:stderr] ${data.toString().trim()}`);
            });
            stream.on('close', (code) => {
              conn.end();
              if (buffer.trim()) onOutput?.(buffer);
              if (code === 0) {
                resolve({ success: true });
              } else {
                reject(new Error(`Script exited with code ${code}`));
              }
            });
          });
        });

        writeStream.on('error', (err) => { conn.end(); reject(err); });
        readStream.pipe(writeStream);
      });
    });

    conn.on('error', (err) => reject(new Error(`SSH connection failed: ${err.message}`)));

    conn.connect({
      host,
      port: 22,
      username,
      privateKey,
      readyTimeout: 30000,
    });
  });
}

module.exports = { runScriptOnAIX };
