-- Single-view point cloud of an M24 hex nut on a bolt, as seen by a depth
-- camera: only camera-facing surfaces are sampled, with incidence-weighted
-- density, sensor noise, and shaded height coloring. Emits TikZ; run via lualatex.

math.randomseed(11)

local AF, TH = 36, 19          -- nut across flats and thickness [mm]
local RH, RB = 12, 11.5        -- nut bore and bolt radius [mm]
local HB, BL = 9, 14           -- bolt end below nut top, visible shaft length [mm]
local S, DOT = 0.055, 0.0075   -- drawing scale [cm/mm], dot radius [cm]
local RHO, NOISE = 3.0, 0.12   -- samples per mm^2, sensor noise [mm]
local EL, AZ = math.rad(50), math.rad(-75)

local c = {math.cos(AZ), math.sin(AZ)}                  -- toward camera, horizontal
local d = {math.cos(EL) * c[1], math.cos(EL) * c[2], math.sin(EL)}
local e1 = {-math.sin(AZ), math.cos(AZ), 0}             -- screen right
local e2 = {-math.sin(EL) * c[1], -math.sin(EL) * c[2], math.cos(EL)}  -- screen up
local tanEL = math.tan(EL)
local R = AF / math.sqrt(3)                             -- hex circumradius = side

local normals = {}
for k = 0, 5 do
  local a = math.rad(60 * k)
  normals[#normals + 1] = {math.cos(a), math.sin(a)}
end
local function inHex(x, y)
  for _, n in ipairs(normals) do
    if x * n[1] + y * n[2] > AF / 2 then return false end
  end
  return true
end
local function gauss()
  return math.sqrt(-2 * math.log(1 - math.random())) * math.cos(2 * math.pi * math.random())
end

-- key light from the upper left of the camera, for Lambertian shading
local l = {d[1] - 0.7 * e1[1] + 0.6 * e2[1], d[2] - 0.7 * e1[2] + 0.6 * e2[2],
           d[3] + 0.6 * e2[3]}
local ln = math.sqrt(l[1]^2 + l[2]^2 + l[3]^2)
l = {l[1] / ln, l[2] / ln, l[3] / ln}

local pts = {}
local function add(x, y, z, cosinc, nx, ny, nz)
  if math.random() < cosinc then
    pts[#pts + 1] = {x + NOISE * gauss(), y + NOISE * gauss(), z + NOISE * gauss(),
      shade = 0.35 + 0.65 * math.max(nx * l[1] + ny * l[2] + nz * l[3], 0)}
  end
end

-- top face (hexagon minus bore)
for _ = 1, math.floor(RHO * (2 * R)^2) do
  local x, y = (2 * math.random() - 1) * R, (2 * math.random() - 1) * R
  if inHex(x, y) and x * x + y * y >= RH * RH then add(x, y, TH, d[3], 0, 0, 1) end
end

-- camera-facing flanks
for _, n in ipairs(normals) do
  local ci = n[1] * d[1] + n[2] * d[2]
  if ci > 0 then
    for _ = 1, math.floor(RHO * R * TH) do
      local u, z = (math.random() - 0.5) * R, math.random() * TH
      add(n[1] * AF / 2 - n[2] * u, n[2] * AF / 2 + n[1] * u, z, ci, n[1], n[2], 0)
    end
  end
end

-- far side of the bore above the bolt end, where the opening does not occlude it
for _ = 1, math.floor(RHO * 2 * math.pi * RH * HB) do
  local phi, h = 2 * math.pi * math.random(), math.random() * HB
  local x, y = RH * math.cos(phi), RH * math.sin(phi)
  local pc = x * c[1] + y * c[2]
  if pc < 0 and h <= -2 * pc * tanEL then add(x, y, TH - h, -pc / RH * math.cos(EL), -x / RH, -y / RH, 0) end
end

-- bolt end face seen through the bore
for _ = 1, math.floor(RHO * (2 * RB)^2) do
  local x, y = (2 * math.random() - 1) * RB, (2 * math.random() - 1) * RB
  local s = HB / tanEL
  local qx, qy = x + c[1] * s, y + c[2] * s
  if x * x + y * y <= RB * RB and qx * qx + qy * qy <= RH * RH then
    add(x, y, TH - HB, d[3], 0, 0, 1)
  end
end

-- bolt shaft below the nut, unless the nut blocks the line of sight
for _ = 1, math.floor(RHO * 2 * math.pi * RB * BL) do
  local phi, z = 2 * math.pi * math.random(), -math.random() * BL
  local x, y = RB * math.cos(phi), RB * math.sin(phi)
  local ci = (x * c[1] + y * c[2]) / RB
  local s = -z / tanEL
  if ci > 0 and not inHex(x + c[1] * s, y + c[2] * s) then
    add(x, y, z, ci * math.cos(EL), x / RB, y / RB, 0)
  end
end

-- height coloring (viridis) with shading, far points drawn first
local dmin, dmax = math.huge, -math.huge
for _, p in ipairs(pts) do
  p.dep = p[1] * d[1] + p[2] * d[2] + p[3] * d[3]
  dmin, dmax = math.min(dmin, p[3]), math.max(dmax, p[3])
end
table.sort(pts, function(a, b) return a.dep < b.dep end)

local cmap = {{0.267, 0.005, 0.329}, {0.231, 0.322, 0.545}, {0.129, 0.569, 0.553},
              {0.369, 0.788, 0.384}, {0.992, 0.906, 0.145}}
local function color(t)
  local s = t * (#cmap - 1)
  local i = math.min(math.floor(s), #cmap - 2)
  local f, a, b = s - i, cmap[i + 1], cmap[i + 2]
  return a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f, a[3] + (b[3] - a[3]) * f
end

for _, p in ipairs(pts) do
  local r, g, b = color(0.25 + 0.75 * (p[3] - dmin) / (dmax - dmin))
  r, g, b = r * p.shade, g * p.shade, b * p.shade
  tex.sprint(string.format(
    "\\fill[fill={rgb,1:red,%.3f;green,%.3f;blue,%.3f}] (%.4f,%.4f) circle (%.4f);",
    r, g, b, S * (p[1] * e1[1] + p[2] * e1[2]),
    S * (p[1] * e2[1] + p[2] * e2[2] + p[3] * e2[3]), DOT))
end
