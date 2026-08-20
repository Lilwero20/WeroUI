# WeroUI

Librería de interfaz (UI) moderna y minimalista para Roblox, con tema azul profesional.

Está diseñada para ser simple, ligera y bonita: creas una ventana, agregas pestañas y llenas cada pestaña con elementos como botones, toggles, sliders, dropdowns, inputs, keybinds, color pickers y más.

## Características

- Ventana arrastrable con barra de título (logo, título, subtítulo).
- Ventana **redimensionable** desde la esquina inferior derecha, con tamaño mínimo/máximo configurable.
- Botón de **minimizar** ("–") que colapsa la ventana hacia arriba dejando solo la barra de título.
- Botón de **cerrar** ("×") y tecla global para abrir/cerrar (por defecto `LeftControl`).
- Icono flotante para abrir/cerrar el menú desde la pantalla.
- Icono personalizado por `assetid` (se muestra con sus colores originales).
- Notificaciones animadas (se deslizan desde la derecha y desaparecen solas).
- Tooltips: casi todos los elementos aceptan `Tooltip` para mostrar ayuda al pasar el mouse.
- **Guardado de configuración**: cualquier elemento con `Flag` puede guardarse y recargarse automáticamente en un archivo (ver sección [Guardado de configuración](#guardado-de-configuración-flags)).
- Dropdowns con búsqueda opcional, selección múltiple, y scroll que se ajusta dinámicamente al contenido real (funciona bien incluso después de `:Refresh()` o al filtrar con el buscador).
- ColorPicker con deslizadores RGB y campo hexadecimal.
- Barra de progreso (`ProgressBar`) además del slider interactivo.
- API programática: casi todos los elementos devuelven un objeto con métodos `:Set()`, `:Refresh()`, etc.

---

## Instalación

Carga la librería directamente desde el repositorio:

```lua
local WeroUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Lilwero20/WeroUI/main/WeroUI.lua"))()
```

---

## Ejemplo mínimo (todo lo básico)

```lua
local WeroUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Lilwero20/WeroUI/main/WeroUI.lua"))()

local Window = WeroUI:CreateWindow({
    Name = "Mi Script",
    Subtitle = "by WeroScripts",
})

local Tab = Window:CreateTab("Principal")

Tab:CreateButton({
    Name = "Hola",
    Callback = function()
        print("Hiciste clic!")
    end,
})
```

---

# API de la Ventana

## `WeroUI:CreateWindow(config)`

Crea y devuelve la ventana principal. Todas las opciones son opcionales.

| Opción                 | Tipo                    | Default                        | Descripción                                              |
| ---------------------- | ------------------------ | ------------------------------ | -------------------------------------------------------- |
| `Name`                 | `string`                 | `"Wero UI"`                    | Nombre que se muestra en la barra de título.             |
| `Subtitle`             | `string`                 | `""`                           | Subtítulo pequeño debajo del nombre.                     |
| `Icon`                 | `number` / `string` / `nil` | `nil` (letra "W")           | Assetid del logo: `123456789` o `"rbxassetid://..."`. Si no se pone, se usa la letra "W". |
| `ToggleKeybind`        | `Enum.KeyCode`           | `Enum.KeyCode.LeftControl`     | Tecla que abre/cierra la ventana.                        |
| `Size`                 | `UDim2`                  | `UDim2.fromOffset(560, 380)`   | Tamaño inicial de la ventana.                             |
| `Resizable`            | `boolean`                | `true`                         | Si `false`, quita el grip de redimensionar.               |
| `MinSize`              | `Vector2`                | `Vector2.new(420, 280)`        | Tamaño mínimo al redimensionar.                            |
| `MaxSize`              | `Vector2`                | `Vector2.new(900, 700)`        | Tamaño máximo al redimensionar.                            |
| `ConfigurationSaving`  | `table`                  | `{}` (desactivado)             | Ver [Guardado de configuración](#guardado-de-configuración-flags). |

```lua
local Window = WeroUI:CreateWindow({
    Name = "WeroHub",
    Subtitle = "by WeroScripts",
    Icon = 98755624629571,
    ToggleKeybind = Enum.KeyCode.LeftControl,
    Size = UDim2.fromOffset(560, 380),
    Resizable = true,
    MinSize = Vector2.new(420, 280),
    MaxSize = Vector2.new(900, 700),
})
```

---

## `Window:CreateTab(nombre, icono)`

Crea una pestaña en la barra lateral y devuelve la pestaña (que es el objeto con todos los métodos `Tab:CreateXxx`).

- `nombre`: `string` — texto visible en la pestaña.
- `icono` *(opcional)*: `number`/`string` — assetid del icono de la pestaña.

```lua
local Tab = Window:CreateTab("Principal")           -- sin icono
local Tab2 = Window:CreateTab("Ajustes", 123456789) -- con icono
```

---

## `Window:Notify({ Title, Content, Duration })`

Muestra una notificación animada en la esquina inferior derecha. Las notificaciones se acumulan hacia arriba y se deslizan desde el borde derecho.

| Opción     | Tipo     | Default          | Descripción                        |
| ---------- | -------- | ---------------- | ----------------------------------- |
| `Title`    | `string` | `"Notificación"` | Título en negrita.                  |
| `Content`  | `string` | `""`             | Texto de la notificación.           |
| `Duration` | `number` | `4`              | Segundos que permanece visible.     |

```lua
Window:Notify({
    Title = "Éxito",
    Content = "Configuración guardada correctamente.",
    Duration = 3,
})
```

---

## `Window:SetOpen(estado)`

Abre o cierra la ventana con animación.

```lua
Window:SetOpen(true)   -- abre
Window:SetOpen(false)  -- cierra
```

## `Window:Toggle()`

Invierte el estado abierto/cerrado.

```lua
Window:Toggle()
```

## `Window:SetMinimized(estado)`

Minimiza o restaura la ventana. Al minimizar se colapsa hacia arriba y queda solo la barra de título (en su misma posición).

```lua
Window:SetMinimized(true)   -- colapsa a la barra de título
Window:SetMinimized(false)  -- restaura
```

## `Window:SetToggleKeybind(tecla)`

Cambia la tecla global de abrir/cerrar.

```lua
Window:SetToggleKeybind(Enum.KeyCode.RightControl)
```

## `Window:SetAccentColor(color)`

Cambia el color de acento (`Accent`, `AccentLight`, `AccentDark`) que usan botones, sliders, dropdowns, etc. Los elementos ya creados toman el nuevo color en su próxima actualización visual.

```lua
Window:SetAccentColor(Color3.fromRGB(255, 90, 160)) -- acento rosa
```

## `Window:Destroy()`

Elimina la ventana y todos sus elementos de la pantalla.

```lua
Window:Destroy()
```

---

## Guardado de configuración (Flags)

Cualquier elemento que tenga `.Set()` (Toggle, Slider, Dropdown, Input, Keybind, ColorPicker) puede recibir una opción `Flag` con un nombre único. Si activás `ConfigurationSaving` en la ventana, el valor de todos los elementos con `Flag` se guarda automáticamente cada vez que cambian, y se vuelve a cargar solo la próxima vez que se ejecute el script.

```lua
local Window = WeroUI:CreateWindow({
    Name = "WeroHub",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "MiConfig",   -- opcional, por defecto usa el Name de la ventana
        Folder = "WeroHub",      -- opcional, por defecto "WeroUI"
    },
})

local Tab = Window:CreateTab("Ajustes")

Tab:CreateToggle({
    Name = "Auto Farm",
    Flag = "AutoFarm",       -- clave única para guardar este valor
    CurrentValue = false,
    Callback = function(v) end,
})
```

También podés guardar o cargar manualmente:

```lua
Window:SaveConfig() -- guarda ahora mismo el estado de todos los Flags
Window:LoadConfig() -- vuelve a leer el archivo y aplica los valores guardados
```

> Requiere que el ejecutor soporte `writefile`/`readfile`/`isfile` (la mayoría de exploits los tienen). Si no están disponibles, `SaveConfig`/`LoadConfig` simplemente no hacen nada (no rompen el script).

---

# API de la Pestaña

Una pestaña se obtiene con `Window:CreateTab(...)` y tiene estos métodos para agregar contenido.

## `Tab:CreateSection(texto)`

Texto separador en mayúsculas (color del tema). Sirve para agrupar elementos.

```lua
Tab:CreateSection("Información")
```

## `Tab:CreateLabel(texto)`

Una tarjeta con texto simple.

```lua
Tab:CreateLabel("Este es un texto informativo.")
```

## `Tab:CreateParagraph({ Title, Content })`

Una tarjeta con un título y un párrafo de contenido. Devuelve un objeto con `:SetDescription(texto)` para actualizar el contenido después.

| Opción    | Tipo     | Descripción                 |
| --------- | -------- | ---------------------------- |
| `Title`   | `string` | Título del párrafo.          |
| `Content` | `string` | Contenido (acepta `\n`).     |

```lua
local Info = Tab:CreateParagraph({
    Title = "Acerca de",
    Content = "Esta librería es fácil de usar y muy bonita.\nSegunda línea.",
})

-- Actualizar el contenido después:
Info:SetDescription("Nuevo contenido del párrafo.")
```

## `Tab:CreateDivider()`

Una línea separadora horizontal.

```lua
Tab:CreateDivider()
```

---

## `Tab:CreateButton({ Name, Description, Tooltip, Callback })`

Botón con color del tema. Devuelve `{ Instance = tarjeta }`.

| Opción        | Tipo                 | Descripción                                |
| ------------- | --------------------- | -------------------------------------------- |
| `Name`        | `string`               | Nombre del botón.                            |
| `Description` | `string` *opcional*    | Texto pequeño debajo del nombre.             |
| `Tooltip`     | `string` *opcional*    | Texto que aparece al pasar el mouse encima.  |
| `Callback`    | `function`             | Se ejecuta al hacer clic (sin argumentos).   |

```lua
local Btn = Tab:CreateButton({
    Name = "Activar",
    Description = "Ejecuta algo al pulsar.",
    Callback = function()
        print("Botón pulsado!")
    end,
})

-- La tarjeta del botón:
print(Btn.Instance)
```

---

## `Tab:CreateToggle({ Name, Description, Tooltip, CurrentValue, Flag, Callback })`

Interruptor de encendido/apagado. Devuelve un objeto con `:Set(valor)` y `.Value`.

| Opción         | Tipo                 | Default    | Descripción                               |
| -------------- | --------------------- | ---------- | ------------------------------------------- |
| `Name`         | `string`               | `"Toggle"` | Nombre.                                     |
| `Description`  | `string` *opcional*    | —          | Texto pequeño debajo.                       |
| `Tooltip`      | `string` *opcional*    | —          | Texto de ayuda al pasar el mouse.           |
| `CurrentValue` | `boolean`              | `false`    | Estado inicial. Si es `true`, el callback se dispara una vez al crear. |
| `Flag`         | `string` *opcional*    | —          | Clave para [guardar/cargar](#guardado-de-configuración-flags) este valor. |
| `Callback`     | `function`             | —          | Recibe el nuevo estado `(boolean)`.         |

```lua
local Toggle = Tab:CreateToggle({
    Name = "Auto-jump",
    Description = "Salta automáticamente.",
    CurrentValue = false,
    Callback = function(value)
        print("Toggle:", value)
    end,
})

-- Cambiar programáticamente:
Toggle:Set(true)
Toggle:Set(false)
```

---

## `Tab:CreateSlider({ Name, Range, Increment, Suffix, Tooltip, CurrentValue, Flag, Callback })`

Barra deslizante con valor numérico. Devuelve un objeto con `:Set(valor)` y `.Value`.

| Opción         | Tipo                | Default    | Descripción                              |
| -------------- | -------------------- | ---------- | ------------------------------------------- |
| `Name`         | `string`              | `"Slider"` | Nombre.                                     |
| `Range`        | `{number, number}`    | `{0, 100}` | Valor mínimo y máximo.                      |
| `Increment`    | `number`              | `1`        | Paso entre valores.                         |
| `Suffix`       | `string` *opcional*   | `""`       | Texto que se agrega después del número (ej. `" px"`, `"%"`). |
| `Tooltip`      | `string` *opcional*   | —          | Texto de ayuda al pasar el mouse.           |
| `CurrentValue` | `number`              | mínimo     | Valor inicial.                              |
| `Flag`         | `string` *opcional*   | —          | Clave para [guardar/cargar](#guardado-de-configuración-flags) este valor. |
| `Callback`     | `function`            | —          | Recibe el valor actual `(number)`.          |

```lua
local Slider = Tab:CreateSlider({
    Name = "Velocidad",
    Range = {0, 200},
    Increment = 5,
    Suffix = " studs/s",
    CurrentValue = 100,
    Callback = function(value)
        print("Velocidad:", value)
    end,
})

-- Cambiar programáticamente:
Slider:Set(150)
print(Slider.Value)
```

---

## `Tab:CreateProgressBar({ Name, Range, CurrentValue })`

Barra de progreso puramente visual (no es interactiva, no tiene `Callback`). Útil para mostrar salud, carga, cooldowns, etc. Devuelve un objeto con `:Set(valor)` y `.Value`.

| Opción         | Tipo                | Default    | Descripción                    |
| -------------- | -------------------- | ---------- | --------------------------------- |
| `Name`         | `string`              | `"Progreso"` | Nombre.                         |
| `Range`        | `{number, number}`    | `{0, 100}` | Valor mínimo y máximo.            |
| `CurrentValue` | `number`              | mínimo     | Valor inicial.                    |

```lua
local Barra = Tab:CreateProgressBar({
    Name = "Salud",
    Range = {0, 100},
    CurrentValue = 100,
})

-- Actualizar el valor (se anima el llenado y el porcentaje):
Barra:Set(45)
```

---

## `Tab:CreateDropdown({ Name, Options, CurrentOption, MultipleOptions, Searchable, MaxVisibleOptions, CloseOnSelect, Tooltip, Flag, Callback })`

Menú desplegable de selección, con scroll automático cuando hay más opciones de las que caben. Devuelve un objeto con `:Refresh(nuevasOpciones)` (alias `:Reload`), `:Set(opcion)` y `.Value`.

| Opción              | Tipo                       | Default              | Descripción                                                      |
| ------------------- | ---------------------------- | ---------------------- | -------------------------------------------------------------------- |
| `Name`              | `string`                     | `"Dropdown"`            | Nombre.                                                           |
| `Options`           | `{string, ...}`               | `{}`                    | Lista de opciones disponibles.                                     |
| `CurrentOption`     | `string` o `{string,...}`     | primera opción          | Opción seleccionada al inicio. Para modo múltiple, una tabla.       |
| `MultipleOptions`   | `boolean`                     | `false`                 | Si `true`, permite seleccionar varias opciones a la vez.            |
| `Searchable`        | `boolean`                     | `false`                 | Si `true`, agrega un buscador arriba de la lista de opciones.       |
| `MaxVisibleOptions` | `number`                      | `5`                     | Cuántas opciones se ven sin scroll; a partir de ahí aparece la barra de scroll. |
| `CloseOnSelect`     | `boolean`                     | `true` en modo simple, `false` en modo múltiple | Si el dropdown se cierra automáticamente al elegir una opción. |
| `Tooltip`           | `string` *opcional*           | —                       | Texto de ayuda al pasar el mouse.                                    |
| `Flag`              | `string` *opcional*           | —                       | Clave para [guardar/cargar](#guardado-de-configuración-flags) este valor. |
| `Callback`          | `function`                    | —                       | Recibe el valor seleccionado.                                        |

La opción (u opciones) seleccionadas se marcan con un check ✓ dentro de la lista. El área de opciones siempre se ajusta a la cantidad real que hay para mostrar, así que sigue funcionando bien después de un `:Refresh()` o al escribir en el buscador.

Modo simple: el callback recibe un `string`.

```lua
local Dropdown = Tab:CreateDropdown({
    Name = "Modo de juego",
    Options = {"Survival", "Creative", "Hardcore"},
    CurrentOption = "Survival",
    Callback = function(value)
        print("Modo:", value)
    end,
})

-- Actualizar opciones dinámicamente:
Dropdown:Refresh({"Nuevo A", "Nuevo B", "Nuevo C"})
```

Modo múltiple: el callback recibe una **tabla** `{ [opcion] = true/false }`.

```lua
local Multi = Tab:CreateDropdown({
    Name = "Permisos",
    Options = {"Admin", "Mod", "Vip", "Builder", "Helper"},
    CurrentOption = {"Vip"},
    MultipleOptions = true,
    Callback = function(values)
        -- values es una tabla: { ["Vip"] = true, ... }
        for opcion, activo in pairs(values) do
            if activo then print("Activo:", opcion) end
        end
    end,
})
```

Con búsqueda y más de 5 opciones (se vuelve scrolleable automáticamente):

```lua
local Zonas = Tab:CreateDropdown({
    Name = "Teletransporte",
    Options = {"Spawn", "Bosque", "Cueva", "Aldea", "Torre", "Puerto", "Montaña"},
    Searchable = true,
    MaxVisibleOptions = 4, -- opcional, por defecto es 5
    Callback = function(value)
        print("Zona:", value)
    end,
})
```

---

## `Tab:CreateInput({ Name, PlaceholderText, CurrentValue, Tooltip, Flag, Callback })`

Campo de texto. Devuelve un objeto con `:Set(texto)` y `.Value`.

| Opción            | Tipo                | Default        | Descripción                              |
| ----------------- | --------------------- | ---------------- | ------------------------------------------- |
| `Name`            | `string`               | `"Input"`         | Nombre del campo.                          |
| `PlaceholderText` | `string`               | `"Escribe..."`    | Texto gris cuando está vacío.              |
| `CurrentValue`    | `string`               | `""`              | Valor inicial.                             |
| `Tooltip`         | `string` *opcional*    | —                 | Texto de ayuda al pasar el mouse.          |
| `Flag`            | `string` *opcional*    | —                 | Clave para [guardar/cargar](#guardado-de-configuración-flags) este valor. |
| `Callback`        | `function`             | —                 | Recibe `(valor, enterPresionado)` cuando el campo pierde el foco. |

```lua
local Input = Tab:CreateInput({
    Name = "Usuario",
    PlaceholderText = "Escribe tu nombre...",
    CurrentValue = "",
    Callback = function(value, enterPressed)
        print("Valor:", value, "| Enter:", enterPressed)
    end,
})

-- Cambiar programáticamente:
Input:Set("WeroScripts")
```

---

## `Tab:CreateKeybind({ Name, CurrentKeybind, Tooltip, Flag, Callback })`

Selector de tecla. Devuelve un objeto con `:Set(tecla)` y `.Value`. Al presionar la tecla asignada (fuera del modo de "escuchar nueva tecla"), también se dispara el `Callback`.

| Opción           | Tipo                       | Default          | Descripción                                    |
| ---------------- | ---------------------------- | ------------------- | --------------------------------------------------- |
| `Name`           | `string`                     | `"Keybind"`          | Nombre.                                            |
| `CurrentKeybind` | `string` o `Enum.KeyCode`     | `Enum.KeyCode.F`      | Tecla inicial, p.ej. `"F"` o `Enum.KeyCode.G`.       |
| `Tooltip`        | `string` *opcional*           | —                     | Texto de ayuda al pasar el mouse.                    |
| `Flag`           | `string` *opcional*           | —                     | Clave para [guardar/cargar](#guardado-de-configuración-flags) este valor. |
| `Callback`       | `function`                    | —                     | Recibe el `Enum.KeyCode` (al reasignar o al presionar la tecla). |

```lua
local Keybind = Tab:CreateKeybind({
    Name = "Fly Key",
    CurrentKeybind = "F",
    Callback = function(key)
        print("Nueva tecla:", key.Name)
    end,
})

-- Cambiar programáticamente:
Keybind:Set(Enum.KeyCode.G)
print(Keybind.Value.Name)
```

---

## `Tab:CreateColorPicker({ Name, Color, Tooltip, Flag, Callback })`

Selector de color RGB con un swatch que abre un panel de 3 deslizadores y un campo hexadecimal. Devuelve un objeto con `:Set(color)` y `.Value`.

| Opción     | Tipo                | Default                | Descripción                          |
| ---------- | --------------------- | ------------------------- | ---------------------------------------- |
| `Name`     | `string`               | `"Color"`                   | Nombre.                                |
| `Color`    | `Color3`               | `Theme.Accent` (azul)       | Color inicial.                         |
| `Tooltip`  | `string` *opcional*    | —                           | Texto de ayuda al pasar el mouse.      |
| `Flag`     | `string` *opcional*    | —                           | Clave para [guardar/cargar](#guardado-de-configuración-flags) este valor. |
| `Callback` | `function`             | —                           | Recibe el `Color3` nuevo.               |

```lua
local Color = Tab:CreateColorPicker({
    Name = "Color del trazo",
    Color = Color3.fromRGB(28, 152, 235),
    Callback = function(color)
        print("Color:", color.R, color.G, color.B)
    end,
})

-- Cambiar programáticamente:
Color:Set(Color3.fromRGB(0, 200, 140))
```

---

# Ejemplo completo

```lua
local WeroUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Lilwero20/WeroUI/main/WeroUI.lua"))()

local Window = WeroUI:CreateWindow({
    Name = "WeroHub",
    Subtitle = "by WeroScripts",
    Icon = 98755624629571,
    ToggleKeybind = Enum.KeyCode.LeftControl,
    Size = UDim2.fromOffset(600, 420),
    ConfigurationSaving = { Enabled = true },
})

local Estado = {
    AutoFly = false,
    Velocidad = 50,
}

local Principal = Window:CreateTab("Principal")
Principal:CreateSection("Bienvenida")
Principal:CreateParagraph({
    Title = "WeroHub",
    Content = "Librería de interfaz profesional con tema azul.\nGracias por usarla!",
})
Principal:CreateDivider()
Principal:CreateButton({
    Name = "Notificación",
    Description = "Muestra una notificación animada.",
    Callback = function()
        Window:Notify({ Title = "WeroHub", Content = "Hola desde un botón!", Duration = 3 })
    end,
})

local Ajustes = Window:CreateTab("Ajustes")
Ajustes:CreateSection("Movimiento")

Ajustes:CreateToggle({
    Name = "Auto Fly",
    Description = "Activa el vuelo automático.",
    CurrentValue = false,
    Flag = "AutoFly",
    Callback = function(v)
        Estado.AutoFly = v
    end,
})

Ajustes:CreateSlider({
    Name = "Velocidad",
    Range = {1, 200},
    Increment = 1,
    CurrentValue = 50,
    Flag = "Velocidad",
    Callback = function(v)
        Estado.Velocidad = v
    end,
})

local Mundo = Window:CreateTab("Mundo")
Mundo:CreateDropdown({
    Name = "Zona",
    Options = {"Spawn", "Centro", "Arena"},
    CurrentOption = "Spawn",
    Searchable = true,
    Callback = function(zona)
        print("Zona:", zona)
    end,
})
Mundo:CreateColorPicker({
    Name = "Color del HUD",
    Callback = function(c)
        print("Nuevo color:", c)
    end,
})
Mundo:CreateProgressBar({
    Name = "Carga del mundo",
    CurrentValue = 100,
})

Window:Notify({
    Title = "WeroHub",
    Content = "Librería cargada correctamente.",
    Duration = 5,
})
```

---

# Tema

La librería expone la tabla de colores en `WeroUI.Theme` si necesitas usarlos en tu propio código, y `WeroUI:SetTheme(patch)` para sobreescribir varios colores a la vez (antes de crear la ventana).

```lua
print(WeroUI.Theme.Accent)      --> Color3 azul eléctrico #1C98EB
print(WeroUI.Theme.Background)  --> Color3 de fondo oscuro

WeroUI:SetTheme({
    Accent = Color3.fromRGB(255, 90, 160),
    Background = Color3.fromRGB(10, 8, 14),
})
```

Para cambiar solo el color de acento **después** de crear la ventana, usá `Window:SetAccentColor(color)` (ver [API de la Ventana](#api-de-la-ventana)).

Paleta principal:

| Constante       | Color        |
| --------------- | ------------ |
| `Background`    | `#070B13`    |
| `Elevated`      | `#111B2A`    |
| `ElevatedLight` | `#1F2F46`    |
| `Stroke`        | `#385880`    |
| `Accent`        | `#1C98EB`    |
| `AccentLight`   | `#84D0FC`    |
| `AccentDark`    | `#0E609E`    |
| `Text`          | `#FAFCFF`    |
| `SubText`       | `#B0C2D4`    |
| `Success`       | `#61DB8A`    |
| `Warning`       | `#FFC457`    |
| `Error`         | `#FF6060`    |

---

# Notas y consejos

- El icono (`Icon`) se muestra con sus **colores originales**; si no pones icono, se muestra la letra **"W"**.
- Los dropdowns muestran barra de scroll automáticamente cuando hay más opciones de las que caben (`MaxVisibleOptions`, por defecto 5); el tamaño visible se recalcula solo, así que funciona bien también con `:Refresh()` y al buscar.
- Casi todos los elementos interactivos aceptan `Tooltip` para mostrar un texto de ayuda al pasar el mouse.
- Cualquier elemento con `.Set()` puede usar `Flag` + `ConfigurationSaving` para guardar y recargar su valor automáticamente entre sesiones.
- Las notificaciones se **deslizan desde la derecha** y se acumulan en la esquina inferior derecha.
- El botón "–" de la barra de título minimiza; el "+" restaura.
- La ventana se puede **redimensionar** arrastrando desde la esquina inferior derecha (desactivalo con `Resizable = false`).
- Los callbacks se envuelven en `pcall`, así que un error en tu código no rompe la interfaz (se muestra un warning en la consola).
- Para el logo de la ventana usa el `assetid` numérico de una imagen de Roblox (por ejemplo un decal).
