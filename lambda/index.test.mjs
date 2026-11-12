import assert from "node:assert/strict";
import test from "node:test";

import { handler } from "./index.mjs";

test("handler returns Hello, World", async () => {
  const response = await handler();

  assert.equal(response.statusCode, 200);
  assert.deepEqual(JSON.parse(response.body), { message: "Hello, World!" });
});