# WeroUI

Librería de interfaz (UI) moderna y minimalista para Roblox, con tema azul profesional.

Está diseñada para ser simple, ligera y bonita: creas una ventana, agregas pestañas y llenas cada pestaña con elementos como botones, toggles, sliders, dropdowns, inputs, keybinds, color pickers y más.

## Características

- Ventana arrastrable con barra de título (logo, título, subtítulo).
- Botón de **minimizar** ("–") que colapsa la ventana hacia arriba dejando solo la barra de título.
- Botón de **cerrar** ("×") y tecla global para abrir/cerrar (por defecto `LeftControl`).
- Icono flotante para abrir/cerrar el menú desde la pantalla.
- Icono personalizado por `assetid` (se muestra con sus colores originales).
- Notificaciones animadas (se deslizan desde la derecha y desaparecen solas).
- Dropdowns que **scrollean** si tienen más de 5 opciones.
- ColorPicker con deslizadores RGB.
- API programática: casi todos los elementos devuelven un objeto con métodos `:Set()`, `:Refresh()`, etc.

---

## Instalación

Sube el archivo `WeroUI.lua` a GitHub (raw) y cárgalo con `loadstring`:

```lua
local WeroUI = loadstring(game:HttpGet("TU_URL_RAW_AQUI"))()
```

Reemplaza `TU_URL_RAW_AQUI` por la URL raw real de tu archivo (por ejemplo: `https://raw.githubusercontent.com/tu-usuario/tu-repo/main/WeroUI.lua`).

---

## Ejemplo mínimo (todo lo básico)

```lua
local WeroUI = loadstring(game:HttpGet("TU_URL_RAW_AQUI"))()

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

| Opción           | Tipo                    | Default                        | Descripción                                              |
| ---------------- | ----------------------- | ------------------------------ | -------------------------------------------------------- |
| `Name`           | `string`                | `"Wero UI"`                    | Nombre que se muestra en la barra de título.             |
| `Subtitle`       | `string`                | `""`                           | Subtítulo pequeño debajo del nombre.                     |
| `Icon`           | `number` / `string` / `nil` | `nil` (letra "W")            | Assetid del logo: `123456789` o `"rbxassetid://..."`. Si no se pone, se usa la letra "W". |
| `ToggleKeybind`  | `Enum.KeyCode`          | `Enum.KeyCode.LeftControl`     | Tecla que abre/cierra la ventana.                        |
| `Size`           | `UDim2`                 | `UDim2.fromOffset(560, 380)`   | Tamaño de la ventana.                                    |

```lua
local Window = WeroUI:CreateWindow({
    Name = "WeroHub",
    Subtitle = "by WeroScripts",
    Icon = 98755624629571,
    ToggleKeybind = Enum.KeyCode.LeftControl,
    Size = UDim2.fromOffset(560, 380),
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
| ---------- | -------- | ---------------- | ---------------------------------- |
| `Title`    | `string` | `"Notificación"` | Título en negrita.                 |
| `Content`  | `string` | `""`             | Texto de la notificación.          |
| `Duration` | `number` | `4`              | Segundos que permanece visible.    |

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

## `Window:Destroy()`

Elimina la ventana y todos sus elementos de la pantalla.

```lua
Window:Destroy()
```

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

Una tarjeta con un título y un párrafo de contenido.

| Opción    | Tipo     | Descripción                 |
| --------- | -------- | --------------------------- |
| `Title`   | `string` | Título del párrafo.         |
| `Content` | `string` | Contenido (acepta `\n`).    |

```lua
Tab:CreateParagraph({
    Title = "Acerca de",
    Content = "Esta librería es fácil de usar y muy bonita.\nSegunda línea.",
})
```

## `Tab:CreateDivider()`

Una línea separadora horizontal.

```lua
Tab:CreateDivider()
```

---

## `Tab:CreateButton({ Name, Description, Callback })`

Botón con color del tema. Devuelve `{ Instance = tarjeta }`.

| Opción        | Tipo       | Descripción                                     |
| ------------- | ---------- | ----------------------------------------------- |
| `Name`        | `string`   | Nombre del botón.                               |
| `Description` | `string` *opcional* | Texto pequeño debajo del nombre. |
| `Callback`    | `function` | Se ejecuta al hacer clic (sin argumentos).      |

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

## `Tab:CreateToggle({ Name, Description, CurrentValue, Callback })`

Interruptor de encendido/apagado. Devuelve un objeto con `:Set(valor)`.

| Opción        | Tipo       | Default | Descripción                               |
| ------------- | ---------- | ------- | ----------------------------------------- |
| `Name`        | `string`   | `"Toggle"` | Nombre.                                |
| `Description` | `string` *opcional* | — | Texto pequeño debajo.         |
| `CurrentValue`| `boolean`  | `false` | Estado inicial. Si es `true`, el callback se dispara una vez al crear. |
| `Callback`    | `function` | —       | Recibe el nuevo estado `(boolean)`.        |

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

## `Tab:CreateSlider({ Name, Range, Increment, CurrentValue, Callback })`

Barra deslizante con valor numérico. Devuelve un objeto con `:Set(valor)` y `.Value`.

| Opción         | Tipo         | Default | Descripción                              |
| -------------- | ------------ | ------- | ---------------------------------------- |
| `Name`         | `string`     | `"Slider"` | Nombre.                               |
| `Range`        | `{number, number}` | `{0, 100}` | Valor mínimo y máximo. |
| `Increment`    | `number`     | `1`     | Paso entre valores.                      |
| `CurrentValue` | `number`     | mínimo  | Valor inicial.                           |
| `Callback`     | `function`   | —       | Recibe el valor actual `(number)`.       |

```lua
local Slider = Tab:CreateSlider({
    Name = "Velocidad",
    Range = {0, 200},
    Increment = 5,
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

## `Tab:CreateDropdown({ Name, Options, CurrentOption, MultipleOptions, Callback })`

Menú desplegable de selección. Si tiene **más de 5 opciones**, aparece una barra de scroll. Devuelve un objeto con `:Refresh(nuevasOpciones)` y `.Value`.

| Opción            | Tipo                  | Default | Descripción                                      |
| ----------------- | --------------------- | ------- | ------------------------------------------------ |
| `Name`            | `string`              | `"Dropdown"` | Nombre.                                      |
| `Options`         | `{string, ...}`       | `{}`    | Lista de opciones disponibles.                   |
| `CurrentOption`   | `string` o `{string,...}` | primera opción | Opción seleccionada al inicio. Para modo múltiple, una tabla. |
| `MultipleOptions` | `boolean`             | `false` | Si `true`, permite seleccionar varias.           |
| `Callback`        | `function`            | —       | Recibe el valor seleccionado.                    |

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

---

## `Tab:CreateInput({ Name, PlaceholderText, CurrentValue, Callback })`

Campo de texto. Devuelve un objeto con `:Set(texto)` y `.Value`.

| Opción            | Tipo       | Default       | Descripción                              |
| ----------------- | ---------- | ------------- | ---------------------------------------- |
| `Name`            | `string`   | `"Input"`     | Nombre del campo.                        |
| `PlaceholderText` | `string`   | `"Escribe..."`| Texto gris cuando está vacío.            |
| `CurrentValue`    | `string`   | `""`          | Valor inicial.                           |
| `Callback`        | `function` | —             | Recibe `(valor, enterPresionado)`.       |

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

## `Tab:CreateKeybind({ Name, CurrentKeybind, Callback })`

Selector de tecla. Devuelve un objeto con `:Set(tecla)` y `.Value`.

| Opción           | Tipo                  | Default     | Descripción                                 |
| ---------------- | --------------------- | ----------- | ------------------------------------------- |
| `Name`           | `string`              | `"Keybind"` | Nombre.                                     |
| `CurrentKeybind` | `string` o `Enum.KeyCode` | `Enum.KeyCode.F` | Tecla inicial, p.ej. `"F"` o `Enum.KeyCode.G`. |
| `Callback`       | `function`            | —           | Recibe el `Enum.KeyCode` elegido.           |

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

## `Tab:CreateColorPicker({ Name, Color, Callback })`

Selector de color RGB con un swatch que abre un panel de 3 deslizadores. Devuelve un objeto con `:Set(color)` y `.Value`.

| Opción     | Tipo        | Default              | Descripción                          |
| ---------- | ----------- | -------------------- | ------------------------------------ |
| `Name`     | `string`    | `"Color"`            | Nombre.                              |
| `Color`    | `Color3`    | `Theme.Accent` (azul) | Color inicial.                       |
| `Callback` | `function`  | —                    | Recibe el `Color3` nuevo.            |

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
local WeroUI = loadstring(game:HttpGet("TU_URL_RAW_AQUI"))()

local Window = WeroUI:CreateWindow({
    Name = "WeroHub",
    Subtitle = "by WeroScripts",
    Icon = 98755624629571,
    ToggleKeybind = Enum.KeyCode.LeftControl,
    Size = UDim2.fromOffset(600, 420),
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
    Callback = function(v)
        Estado.AutoFly = v
    end,
})

Ajustes:CreateSlider({
    Name = "Velocidad",
    Range = {1, 200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        Estado.Velocidad = v
    end,
})

local Mundo = Window:CreateTab("Mundo")
Mundo:CreateDropdown({
    Name = "Zona",
    Options = {"Spawn", "Centro", "Arena"},
    CurrentOption = "Spawn",
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

Window:Notify({
    Title = "WeroHub",
    Content = "Librería cargada correctamente.",
    Duration = 5,
})
```

---

# Tema

La librería expone la tabla de colores en `WeroUI.Theme` si necesitas usarlos en tu propio código:

```lua
print(WeroUI.Theme.Accent)      --> Color3 azul eléctrico #1C98EB
print(WeroUI.Theme.Background)  --> Color3 de fondo oscuro
```

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
| `Error`         | `#FF6060`    |

---

# Notas y consejos

- El icono (`Icon`) se muestra con sus **colores originales**; si no pones icono, se muestra la letra **"W"**.
- Los dropdowns con más de **5 opciones** muestran una barra de scroll.
- Las notificaciones se **deslizan desde la derecha** y se acumulan en la esquina inferior derecha.
- El botón "–" de la barra de título minimiza; el "+" restaura.
- Los callbacks se envuelven en `pcall`, así que un error en tu código no rompe la interfaz (se muestra un warning en la consola).
- Para el logo de la ventana usa el `assetid` numérico de una imagen de Roblox (por ejemplo un decal).
