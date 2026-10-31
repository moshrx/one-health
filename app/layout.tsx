import type { Metadata } from 'next';
import './globals.css';
export const metadata: Metadata = { title: 'One Health · Clinic workspace', description: 'A thoughtful workspace for continuity of care.' };
export default function RootLayout({ children }: { children: React.ReactNode }) { return <html lang="en"><body>{children}</body></html>; }
