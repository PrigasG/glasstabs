import js from "@eslint/js";
import globals from "globals";

export default [
  {
    files: ["inst/www/glass.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "script",
      globals: {
        ...globals.browser,
        Shiny: "readonly"
      }
    },
    rules: {
      ...js.configs.recommended.rules,
      "no-unused-vars": ["error", { "args": "none", "caughtErrors": "none" }]
    }
  }
];
