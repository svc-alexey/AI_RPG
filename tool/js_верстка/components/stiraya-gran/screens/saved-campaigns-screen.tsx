"use client";

import { ArrowLeft, BookOpen, Clock, Plus, Trash2, Play } from "lucide-react";

interface Campaign {
  id: string;
  name: string;
  character: string;
  genre: string;
  lastPlayed: string;
  turn: number;
}

interface SavedCampaignsScreenProps {
  onNavigate: (screen: string) => void;
  campaigns?: Campaign[];
}

export function SavedCampaignsScreen({ onNavigate, campaigns = [] }: SavedCampaignsScreenProps) {
  return (
    <div className="min-h-screen bg-[#0A0908]">
      {/* Subtle background glow */}
      <div className="pointer-events-none fixed inset-0">
        <div 
          className="absolute right-0 top-0 h-[400px] w-[400px] rounded-full opacity-30"
          style={{
            background: 'radial-gradient(circle, rgba(200,121,65,0.1) 0%, transparent 70%)',
          }}
        />
      </div>

      <div className="relative z-10 p-6 md:p-8 lg:p-12">
        {/* Header */}
        <header className="mb-12 flex items-center gap-6">
          <button
            onClick={() => onNavigate("home")}
            className="flex h-12 w-12 items-center justify-center rounded-full border border-[#1A1816] bg-[#0F0D0B] text-[#7A7570] transition-all hover:border-[#C87941]/30 hover:text-[#D4956A]"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <div>
            <h1 className="font-serif text-3xl text-[#E8E4E0] md:text-4xl">
              Сохранённые миры
            </h1>
            <p className="mt-1 text-sm text-[#5A5550]">
              {campaigns.length > 0 ? `${campaigns.length} историй ждут продолжения` : 'Ваши истории появятся здесь'}
            </p>
          </div>
        </header>

        {/* Content */}
        <div className="mx-auto max-w-5xl">
          {campaigns.length === 0 ? (
            <div className="flex min-h-[50vh] flex-col items-center justify-center text-center">
              <div className="relative mb-8">
                <div className="flex h-24 w-24 items-center justify-center rounded-2xl border border-[#1A1816] bg-[#0F0D0B]">
                  <BookOpen className="h-10 w-10 text-[#5A5550]" />
                </div>
                <div className="absolute -bottom-1 -right-1 h-4 w-4 animate-flicker rounded-full bg-[#C87941]/50" />
              </div>
              <h2 className="mb-3 font-serif text-2xl text-[#E8E4E0]">
                Пока нет сохранений
              </h2>
              <p className="mb-10 max-w-md text-[#7A7570]">
                Создайте первую кампанию и погрузитесь в историю, которая запомнит каждый ваш выбор
              </p>
              <button
                onClick={() => onNavigate("new-campaign")}
                className="group flex items-center gap-3 rounded-full border border-[#C87941]/30 bg-[#C87941]/10 px-8 py-4 text-[#C87941] transition-all hover:border-[#C87941]/50 hover:bg-[#C87941]/20"
              >
                <Plus className="h-5 w-5" />
                <span className="font-medium">Создать новую кампанию</span>
              </button>
            </div>
          ) : (
            <div className="space-y-4">
              {campaigns.map((campaign) => (
                <div
                  key={campaign.id}
                  className="group relative overflow-hidden rounded-2xl border border-[#1A1816] bg-[#0F0D0B] p-6 transition-all duration-300 hover:border-[#C87941]/20 hover:bg-[#141210]"
                >
                  <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                    {/* Campaign info */}
                    <div className="flex-1">
                      <div className="mb-1 flex items-center gap-3">
                        <h3 className="font-serif text-xl text-[#E8E4E0]">
                          {campaign.name}
                        </h3>
                        <span className="rounded-full bg-[#C87941]/10 px-3 py-0.5 text-xs text-[#D4956A]">
                          {campaign.genre}
                        </span>
                      </div>
                      <p className="text-sm text-[#7A7570]">{campaign.character}</p>
                      
                      <div className="mt-4 flex items-center gap-6 text-xs text-[#5A5550]">
                        <div className="flex items-center gap-2">
                          <Clock className="h-3.5 w-3.5" />
                          <span>{campaign.lastPlayed}</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <span className="text-[#7A7570]">Ход {campaign.turn}</span>
                        </div>
                      </div>
                    </div>

                    {/* Actions */}
                    <div className="flex items-center gap-3">
                      <button 
                        className="text-[#5A5550] transition-colors hover:text-[#A64B4B]"
                        title="Удалить"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => onNavigate("game")}
                        className="flex items-center gap-2 rounded-full border border-[#C87941]/30 bg-transparent px-6 py-2.5 text-sm text-[#C87941] transition-all hover:bg-[#C87941]/10"
                      >
                        <Play className="h-4 w-4" />
                        <span>Продолжить</span>
                      </button>
                    </div>
                  </div>

                  {/* Subtle hover glow */}
                  <div className="absolute -right-10 top-1/2 h-20 w-20 -translate-y-1/2 rounded-full bg-[#C87941]/10 opacity-0 blur-2xl transition-opacity group-hover:opacity-100" />
                </div>
              ))}

              {/* Add new campaign card */}
              <button
                onClick={() => onNavigate("new-campaign")}
                className="flex w-full items-center justify-center gap-3 rounded-2xl border border-dashed border-[#2A2520] bg-transparent p-8 text-[#5A5550] transition-all hover:border-[#C87941]/30 hover:text-[#D4956A]"
              >
                <Plus className="h-5 w-5" />
                <span>Начать новую историю</span>
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
