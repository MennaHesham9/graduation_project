import type { ReactNode } from "react";

type StatCardProps = {
  icon: ReactNode;
  line1: string;
  line2: string;
  /** When "second", line2 is visually emphasized (larger). When "first", line1 is emphasized. */
  emphasize: "first" | "second";
};

export function StatCard({ icon, line1, line2, emphasize }: StatCardProps) {
  const primaryClass = "text-xl font-semibold text-gray-900";
  const secondaryClass = "text-sm font-medium text-gray-500";

  return (
    <div className="flex flex-col items-center justify-center rounded-2xl bg-white px-4 py-6 text-center shadow-md">
      <div className="mb-3 flex items-center justify-center">{icon}</div>
      {emphasize === "second" ? (
        <>
          <p className={secondaryClass}>{line1}</p>
          <p className="mt-2 text-4xl leading-none">{line2}</p>
        </>
      ) : (
        <>
          <p className={`${primaryClass} text-2xl`}>{line1}</p>
          <p className={`${secondaryClass} mt-1`}>{line2}</p>
        </>
      )}
    </div>
  );
}
