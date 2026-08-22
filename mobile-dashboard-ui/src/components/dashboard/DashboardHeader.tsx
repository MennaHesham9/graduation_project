import { Bell } from "lucide-react";
import { IconCircleButton } from "./IconCircleButton";

export function DashboardHeader() {
  return (
    <header className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-[#2ec4b6] to-[#1b9aaa] p-6 pb-8 pt-7 shadow-lg">
      <div className="absolute right-5 top-5">
        <IconCircleButton icon={Bell} label="Notifications" />
      </div>

      <div className="pr-14">
        <h1 className="text-2xl font-bold tracking-tight text-white">Hello, Sarah 👋</h1>
        <p className="mt-1 text-base font-medium text-white/90">Let&apos;s make today amazing</p>
      </div>

      <blockquote className="mt-6 rounded-xl border border-white/20 bg-white/15 p-4 text-sm leading-relaxed text-white/95 backdrop-blur-sm">
        <p className="font-medium">
          &ldquo;The only way to do great work is to love what you do.&rdquo; — Steve Jobs
        </p>
      </blockquote>
    </header>
  );
}
