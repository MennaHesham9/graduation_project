import { Video } from "lucide-react";

export function NextSessionCard() {
  return (
    <section
      className="relative z-10 -mt-10 mx-0 flex items-center gap-3 rounded-2xl bg-white p-4 shadow-lg ring-1 ring-black/5"
      aria-labelledby="next-session-heading"
    >
      <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-[#2ec4b6]/15 text-[#1b9aaa]">
        <Video className="h-6 w-6" strokeWidth={2} aria-hidden />
      </div>
      <div className="min-w-0 flex-1">
        <h2 id="next-session-heading" className="text-xs font-semibold uppercase tracking-wide text-gray-400">
          Next Session
        </h2>
        <p className="mt-0.5 truncate text-base font-semibold text-gray-900">Dr. Michael Chen</p>
        <p className="text-sm font-medium text-gray-500">Today, 2:00 PM</p>
      </div>
      <button
        type="button"
        className="shrink-0 rounded-xl bg-[#1b9aaa] px-4 py-2.5 text-sm font-semibold text-white shadow-md transition hover:bg-[#178a9a] active:scale-[0.98]"
      >
        Join Now
      </button>
    </section>
  );
}
