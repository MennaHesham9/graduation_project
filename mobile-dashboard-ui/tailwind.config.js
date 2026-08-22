/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
      },
      colors: {
        teal: {
          brand: "#2ec4b6",
          deep: "#1b9aaa",
        },
      },
    },
  },
  plugins: [],
};
