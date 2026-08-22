import { useState } from "react";
import { ClipboardList, Heart, ListChecks, Users } from "lucide-react";
import { ActionCard } from "./dashboard/ActionCard";
import { BottomNav } from "./dashboard/BottomNav";
import { DashboardHeader } from "./dashboard/DashboardHeader";
import { GoalsProgress } from "./dashboard/GoalsProgress";
import { NextSessionCard } from "./dashboard/NextSessionCard";
import { StatCard } from "./dashboard/StatCard";

type NavId = "home" | "tasks" | "goals" | "sessions" | "profile";

export function MobileDashboard() {
  const [activeNav, setActiveNav] = useState<NavId>("home");

  return (
    <div
      className="relative mx-auto min-h-[820px] w-full max-w-[390px] overflow-hidden rounded-[2rem] bg-[#f3f4f6] shadow-xl ring-1 ring-black/5"
      role="region"
      aria-label="Dashboard"
    >
      <div className="max-h-[min(100dvh,900px)] overflow-y-auto px-4 pb-28 pt-5">
        <DashboardHeader />
        <NextSessionCard />

        <div className="mt-5 grid grid-cols-2 gap-3">
          <StatCard
            icon={<Heart className="h-8 w-8 text-rose-500" strokeWidth={2} />}
            line1="Today's Mood"
            line2="😊"
            emphasize="second"
          />
          <StatCard
            icon={<ListChecks className="h-8 w-8 text-[#1b9aaa]" strokeWidth={2} />}
            line1="3 / 7"
            line2="Tasks Done"
            emphasize="first"
          />
        </div>

        <div className="mt-6">
          <GoalsProgress />
        </div>

        <div className="mt-6 grid grid-cols-2 gap-3">
          <ActionCard
            icon={Users}
            title="Explore Coaches"
            iconBgClass="bg-emerald-100"
            iconColorClass="text-emerald-600"
          />
          <ActionCard
            icon={ClipboardList}
            title="Assessments"
            iconBgClass="bg-orange-100"
            iconColorClass="text-orange-500"
          />
        </div>
      </div>

      <BottomNav active={activeNav} onChange={setActiveNav} />
    </div>
  );
}
