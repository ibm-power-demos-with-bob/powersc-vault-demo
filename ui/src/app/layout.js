import './globals.scss';
import { Providers } from './providers';

export const metadata = {
  title: 'PowerSC + Vault Demo',
  description: 'IBM PowerSC + HashiCorp Vault Certificate Lifecycle Management',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
