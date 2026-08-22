import { ProgressBar } from "./ProgressBar";

export function GoalsProgress() {
  return (
    <section className="mt-2" aria-labelledby="goals-progress-title">
      <h2 id="goals-progress-title" className="mb-4 text-lg font-bold text-gray-900">
        Goals Progress
      </h2>
      <div className="space-y-5 rounded-2xl bg-white p-5 shadow-md">
        <ProgressBar label="Improve Communication" value={75} barClassName="bg-[#2ec4b6]" />
        <ProgressBar label="Build Confidence" value={60} barClassName="bg-[#0891b2]" />
      </div>
    </section>
  );
}
