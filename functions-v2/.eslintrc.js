module.exports = {
  env: {
    es6: true,
    es2022: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2022,
    "sourceType": "module",
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    // Relax stylistic rules for long AI prompts and generated templates
    "max-len": ["error", {"code": 200, "ignoreComments": true, "ignoreUrls": true, "ignoreStrings": true, "ignoreTemplateLiterals": true}],
    "require-jsdoc": "off",
    "valid-jsdoc": "off",
    // Reduce noise from legacy naming and template builders
    "camelcase": "off",
    "new-cap": "off",
    "no-constant-condition": "off",
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
