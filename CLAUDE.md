# Project Guidelines

## JavaScript/TypeScript Guide

Act as a top-tier software engineer with serious JavaScript/TypeScript discipline to carefully implement high quality software.

### Before Writing Code

- Read the lint and formatting rules.
- Observe the project's relevant existing code.
- Conform to existing code style, patterns, and conventions unless directed otherwise. Note: these instructions count as "directed otherwise" unless the user explicitly overrides them.

### Principles

- DOT
- YAGNI
- KISS
- DRY
- SDA - Self Describing APIs
- Simplicity - "Simplicity is removing the obvious, and adding the meaningful."
  - Obvious stuff gets hidden in the abstraction.
  - Meaningful stuff is what needs to be customized and passed in as parameters.
  - Functions should have default parameters whenever it makes sense so that callers can supply only what is different from the default.

### Constraints

- Be concise.
- Favor functional programming; keep functions short, pure, and composable.
- Favor map, filter, reduce over manual loops.
- Prefer immutability; use const, spread, and rest operators instead of mutation.
- One job per function; separate mapping from IO.
- Obey the projects lint and formatting rules.
- Omit needless code and variables; prefer composition with partial application and point-free style.
- Chain operations rather than introducing intermediate variables, e.g. `[x].filter(p).map(f)`
- Avoid loose procedural sequences; compose clear pipelines instead.
- Avoid `class` and `extends` as much as possible. Prefer composition of functions and data structures over inheritance.
- Keep related code together; group by feature, not by technical type.
- Put statements and expressions in positive form.
- Use parallel code for parallel concepts.
- Avoid null/undefined arguments; use options objects instead.
- Use concise syntax: arrow functions, object destructuring, array destructuring, template literals.
- Avoid verbose property assignments. bad: `const a = obj.a;` good: `const { a } = obj;`
- Assign reasonable defaults directly in function signatures.
  `const createExpectedUser = ({ id = createId(), name = '', description = '' } = {}) => ({ id, name, description });`
- Principle: SDA. This means:
  Parameter values should be explicitly named and expressed in function signatures:
    Bad: `const createUser = (payload = {}) => ({`
    Good: `const createUser = ({ id = createId(), name = '', description = ''} = {}) =>`
    Notice how default values also provide hints for type inference.
- Avoid IIFEs. Use block scopes, modules, or normal arrow functions instead. Principle: KISS
- Avoid using || for defaults. Use parameter defaults instead. See above.
- Prefer async/await or asyncPipe over raw promise chains.
- Use strict equality (===).
- Modularize by feature; one concern per file or function; prefer named exports.

### Naming Constraints

- Use active voice.
- Use clear, consistent naming.
- Functions should be verbs. e.g. `increment()`, `filter()`.
- Predicates and booleans should read like yes/no questions. e.g. `isActive`, `hasPermission`.
- Prefer standalone verbs over noun.method. e.g. `createUser()` not `User.create()`.
- Avoid noun-heavy and redundant names. e.g. `filter(fn, array)` not `matchingItemsFromArray(fn, array)`.
- Avoid "doSomething" style. e.g. `notify()` not `Notifier.doNotification()`.
- Lifecycle methods: prefer `beforeX` / `afterX` over `willX` / `didX`. e.g. `beforeUpdate()`.
- Use strong negatives over weak ones: `isEmpty(thing)` not `!isDefined(thing)`.
- Mixins and function decorators use `with${Thing}`. e.g. `withUser`, `withFeatures`, `withAuth`.

### Comments

- Favor docblocks for public APIs - but keep them minimal.
- Ensure that any comments are necessary and add value. Never reiterate the style guides. Avoid obvious redundancy with the code, but short one-line comments that aid scannability are okay.
- Comments should stand-alone months or years later. Assume that the reader is not familiar with the task plan or epic.

## React Guide

Act as a top-tier software engineer with extensive React ecosystem knowledge to build high-quality fullstack web applications.

### Before Writing Code

- Observe the project's relevant existing code.
- Conform to existing code style, patterns, and conventions unless directed otherwise. Note: these instructions count as "directed otherwise" unless the user explicitly overrides them.

### Principles

- Display/container component pattern
  - Split your component into display components, which are pure functions that map props to JSX, and container components, which are (optional) stateful components that wrap one display component.
  - Then compose them together in the parent or page/route component.

### React Constraints

- Be concise.
- You're using React Router V7 (the successor to Remix).
- Use ShadCN/ui for components. If a component is missing, install it.
- Modularize by feature; one concern per file or component; prefer named exports.
- This project uses TailwindCSS V4, so you can use things like container queries and child selectors.

### React Naming Constraints

- Use clear, descriptive, consistent naming.
- Components should be postfixed with `Component`.
- Props should be the component's name, postfixed with `ComponentProps`.

### Type Constraints

- Use proper React TypeScript types: MouseEventHandler<HTMLButtonElement>, ChangeEventHandler<HTMLInputElement>, ReactNode, React.Ref<T>, ComponentProps<'element'>, etc. Never use generic () => void or (event: any) => void.
- When extending HTML elements or existing components, use ComponentProps to inherit their props: ComponentProps<'input'>, ComponentProps<'button'>, ComponentProps<typeof ExistingComponent>.
- This project uses Prisma. If a prop comes from a database entity, use the entities type for it, e.g.:
  - type UserMenuProps = Pick<UserAccount, 'id' | 'name' | 'email'> & {
      onLogout: MouseEventHandler<HTMLInputElement>;
      organizationName: Organization['name'];
    }
- When using server/database return types: Awaited<ReturnType<typeof serverFunction>>, wrap with NonNullable<> if guaranteed to exist.

### Form Constraints

- For react-hook-form + Zod forms:
  - Export schema types: export type Schema = z.infer<typeof schema>
  - Export error types: export type SchemaErrors = FieldErrors<Schema>
  - Optionally include intent field: intent: z.literal('actionName')
  - Pass translation keys (not translated strings) in validation error messages
- For loading/submission states:
  - Use consistent naming: isSubmitting = false, isLoading{Action} = false, is{Action}ing{Entity} = false
  - Always provide default values in function signature
  - Disable forms with fieldset disabled={isSubmitting || isLoading} instead of individual disabled props
- For form components:
  - Accept errors?: SchemaErrors (always optional)
  - Accept children?: ReactNode for composition
  - Use FormProvider for parent, useFormContext for nested components
  - Provide complete defaultValues object to useForm with all fields initialized

### Accessibility Constraints

- For interactive components, provide aria props with defaults:
  - *AriaLabel props for screen readers (e.g., countryAriaLabel = 'Select country')
  - *Placeholder props for empty states
  - FormControl handles aria-describedby and aria-invalid automatically

### Internationalization Constraints

- Use useTranslation with namespace and keyPrefix: const { t } = useTranslation('namespace', { keyPrefix: 'section' });
- Use Trans component for interpolation with links/components.
- FormMessage components handle translation of error keys automatically.

## Facade Functions

These constraints apply only to functions in `*-model.ts` files.

- Function names must follow `<action><Entity><OptionalWith...><DataSource><OptionalBy...>()` pattern.
- Allowed actions: save | retrieve | update | delete.
- Entity names are singular, in PascalCase.
- Use "With..." to indicate included relations before "From/In/ToDatabase".
- Use "By..." to indicate lookup key(s) last; key names must match schema fields exactly.
- Use "And" to chain multiple included relations or keys.
- Use "ToDatabase" for create, "FromDatabase" for reads, "InDatabase" for updates, "FromDatabase" for deletes.
- Facades must perform a single database operation (no business logic).
- Facades must always return raw Prisma results (no transformations).
- Include JSDoc with description, @param, and @returns tags matching the function name and purpose.
- Prefer explicit Prisma includes/selects; avoid `include: { *: true }`.
- Function bodies must use the `prisma.<entity>.<operation>` pattern directly.

## Testing

- Use Vitest with describe, expect, and test.
- Tests must use the "given: ..., should: ..." prose format.
- Colocate tests with functions. Test files should be in the same folder as the implementation file.
- Use cuid2 for IDs unless specified otherwise.
- Capture `actual` and `expected` values in variables before asserting with `toEqual`.
- Avoid `expect.any(Constructor)` in assertions. Expect specific values instead.
