Deno.serve(async (req) => {
  const { name = "World" } = await req.json().catch(() => ({}));
  return new Response(JSON.stringify({ message: `Hello ${name}!` }), {
    headers: { "Content-Type": "application/json" },
  });
});
