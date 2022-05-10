module.exports = {
  env: {
    browser: false,
    es2021: true,
    mocha: true,
    node: true
  },
  plugins: ["@typescript-eslint"],
  extends: [
    "standard",
    "eslint:recommended",
    "plugin:@typescript-eslint/eslint-recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaVersion: 12
  },
  rules: {
    quotes: [2, "double"],
    "node/no-unsupported-features/es-syntax": "off",
    "node/no-unpublished-import": "off",
    "node/no-missing-import": "off",
    camelcase: "off",
    "@typescript-eslint/no-non-null-assertion": "off",
    "space-before-function-paren": "off"
  }
}
