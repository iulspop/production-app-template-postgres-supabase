import { describe, expect, test } from "vitest";

import { loader } from "./images";

const createRequest = (src: string) =>
  new Request(
    `http://localhost:5173/api/images?src=${encodeURIComponent(src)}&w=100&h=100`,
  );

describe("api/images loader", () => {
  test("given: missing src param, should: return 400", async () => {
    const request = new Request("http://localhost:5173/api/images");

    const response = await loader({
      context: {} as never,
      params: {},
      request,
      unstable_pattern: "/api/images",
    }).catch((e: Response) => e);

    expect(response).toBeInstanceOf(Response);
    expect((response as Response).status).toEqual(400);
  });

  test("given: valid local image src, should: return response with cache headers", async () => {
    const request = createRequest("/images/app-light.png");

    const response = await loader({
      context: {} as never,
      params: {},
      request,
      unstable_pattern: "/api/images",
    });

    expect(response).toBeInstanceOf(Response);
    expect(response.headers.get("Cache-Control")).toEqual(
      "public, max-age=31536000, immutable",
    );
  });
});
