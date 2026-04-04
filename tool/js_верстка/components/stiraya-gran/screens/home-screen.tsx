"use client";

import { useState } from "react";
import { ArrowRight, Sparkles, BookMarked, Cog } from "lucide-react";

interface HomeScreenProps {
  onNavigate: (screen: string) => void;
}

export function HomeScreen({ onNavigate }: HomeScreenProps) {
  const [hoveredCard, setHoveredCard] = useState<string | null>(null);

  return (
    <div className="relative min-h-screen overflow-hidden bg-[#0A0908]">
      {/* Animated background with candle-like glow */}
      <div className="pointer-events-none absolute inset-0">
        {/* Central warm glow */}
        <div 
          className="absolute left-1/2 top-1/3 h-[600px] w-[600px] -translate-x-1/2 -translate-y-1/2 animate-glow-pulse rounded-full"
          style={{
            background: 'radial-gradient(circle, rgba(200,121,65,0.15) 0%, rgba(200,121,65,0.05) 40%, transparent 70%)',
          }}
        />
        {/* Subtle noise texture overlay */}
        <div 
          className="absolute inset-0 opacity-[0.03]"
          style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E")`,
          }}
        />
      </div>

      {/* Main content */}
      <div className="relative z-10 flex min-h-screen flex-col">
        {/* Top bar - minimal */}
        <header className="flex items-center justify-between px-6 py-6 md:px-12 lg:px-20">
          <div className="flex items-center gap-2 text-[#7A7570]">
            <span className="text-xs font-medium uppercase tracking-[0.25em]">
              Narrative AI RPG
            </span>
          </div>
          <button 
            onClick={() => onNavigate("settings")}
            className="rounded-full p-2 text-[#7A7570] transition-colors hover:bg-[#1A1816] hover:text-[#D4956A]"
          >
            <Cog className="h-5 w-5" />
          </button>
        </header>

        {/* Hero section */}
        <main className="flex flex-1 flex-col items-center justify-center px-6 pb-20 md:px-12">
          {/* Title with dramatic typography */}
          <div className="mb-16 text-center">
            <h1 className="mb-6 font-serif text-6xl font-light leading-[0.9] tracking-tight text-[#E8E4E0] md:text-8xl lg:text-9xl">
              <span className="block">Стирая</span>
              <span className="block text-warm-gradient">Грань</span>
            </h1>
            
            <p className="mx-auto mb-8 max-w-md font-serif text-lg italic text-[#7A7570] md:text-xl">
              История отвечает на твой выбор
            </p>

            {/* Minimal decorative line */}
            <div className="mx-auto flex items-center gap-4">
              <div className="h-px w-16 bg-gradient-to-r from-transparent to-[#C87941]/50" />
              <Sparkles className="h-4 w-4 animate-flicker text-[#C87941]" />
              <div className="h-px w-16 bg-gradient-to-l from-transparent to-[#C87941]/50" />
            </div>
          </div>

          {/* Action cards - bento style */}
          <div className="grid w-full max-w-4xl gap-4 md:grid-cols-2 lg:grid-cols-3">
            {/* Main CTA - Start Story */}
            <button
              onClick={() => onNavigate("new-campaign")}
              onMouseEnter={() => setHoveredCard("start")}
              onMouseLeave={() => setHoveredCard(null)}
              className="group relative col-span-1 overflow-hidden rounded-2xl border border-[#C87941]/20 bg-gradient-to-br from-[#C87941]/10 to-transparent p-8 text-left transition-all duration-500 hover:border-[#C87941]/40 hover:shadow-[0_0_60px_rgba(200,121,65,0.15)] md:col-span-2 lg:col-span-2"
            >
              <div className="relative z-10">
                <div className="mb-4 inline-flex rounded-full bg-[#C87941]/20 p-3">
                  <Sparkles className="h-6 w-6 text-[#C87941]" />
                </div>
                <h2 className="mb-2 font-serif text-2xl text-[#E8E4E0]">
                  Начать новую историю
                </h2>
                <p className="mb-6 text-sm text-[#7A7570]">
                  ИИ станет вашим рассказчиком в мире, который помнит каждое решение
                </p>
                <div className="flex items-center gap-2 text-[#C87941]">
                  <span className="text-sm font-medium">Создать кампанию</span>
                  <ArrowRight className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                </div>
              </div>
              {/* Hover glow effect */}
              <div 
                className={`absolute -right-20 -top-20 h-40 w-40 rounded-full bg-[#C87941]/20 blur-3xl transition-opacity duration-500 ${hoveredCard === "start" ? "opacity-100" : "opacity-0"}`}
              />
            </button>

            {/* Continue */}
            <button
              onClick={() => onNavigate("saved")}
              onMouseEnter={() => setHoveredCard("continue")}
              onMouseLeave={() => setHoveredCard(null)}
              className="group relative overflow-hidden rounded-2xl border border-[#1A1816] bg-[#0F0D0B] p-6 text-left transition-all duration-300 hover:border-[#C87941]/20 hover:bg-[#141210]"
            >
              <div className="mb-4 inline-flex rounded-full bg-[#1A1816] p-3 transition-colors group-hover:bg-[#C87941]/10">
                <BookMarked className="h-5 w-5 text-[#7A7570] transition-colors group-hover:text-[#D4956A]" />
              </div>
              <h3 className="mb-1 font-serif text-lg text-[#E8E4E0]">Продолжить</h3>
              <p className="text-xs text-[#7A7570]">Вернуться в сохранённый мир</p>
            </button>
          </div>

          {/* Feature tags - subtle */}
          <div className="mt-16 flex flex-wrap justify-center gap-6 text-xs text-[#5A5550]">
            <div className="flex items-center gap-2">
              <div className="h-1 w-1 rounded-full bg-[#C87941]/50" />
              <span>Живой рассказчик</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="h-1 w-1 rounded-full bg-[#C87941]/50" />
              <span>Выбор с последствиями</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="h-1 w-1 rounded-full bg-[#C87941]/50" />
              <span>Миры на грани жанров</span>
            </div>
          </div>
        </main>

        {/* Bottom hint */}
        <footer className="pb-8 text-center">
          <p className="text-xs uppercase tracking-[0.3em] text-[#3A3530]">
            Нарративная RPG с ИИ
          </p>
        </footer>
      </div>
    </div>
  );
}
