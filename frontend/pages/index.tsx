import React from 'react';
import Head from 'next/head';
import { Dashboard } from '../components/Dashboard';
import { Header } from '../components/Header';
import { Sidebar } from '../components/Sidebar';

export default function Home() {
  return (
    <>
      <Head>
        <title>Paltalabs - DeFi Platform on Stellar</title>
        <meta name="description" content="Comprehensive DeFi platform built on Stellar blockchain" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <div className="min-h-screen bg-gray-50">
        <Header />
        <div className="flex">
          <Sidebar />
          <main className="flex-1 p-6">
            <Dashboard />
          </main>
        </div>
      </div>
    </>
  );
}
