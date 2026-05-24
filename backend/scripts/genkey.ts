import { generateKeyPairSync } from 'node:crypto';
import { writeFileSync, mkdirSync } from 'node:fs';
import { join } from 'node:path';

const keysDir = join(import.meta.dir, '..', 'keys');

mkdirSync(keysDir, { recursive: true });

console.log('Generating RSA 2048-bit key pair...');

const { privateKey, publicKey } = generateKeyPairSync('rsa', {
  modulusLength: 2048,
  publicKeyEncoding: { type: 'spki', format: 'pem' },
  privateKeyEncoding: { type: 'pkcs8', format: 'pem' },
});

const privateKeyPath = join(keysDir, 'private.pem');
const publicKeyPath = join(keysDir, 'public.pem');

writeFileSync(privateKeyPath, privateKey);
writeFileSync(publicKeyPath, publicKey);

console.log('Done:');
console.log(`  private key: ${privateKeyPath}`);
console.log(`  public key:  ${publicKeyPath}`);
