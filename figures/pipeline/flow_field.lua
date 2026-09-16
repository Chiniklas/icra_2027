-- Flow-matching velocity field for a 1-D toy action distribution.
-- The field is the exact minimizer of the flow-matching loss for the linear
-- path U^lambda = (1-lambda) U^0 + lambda U^D, and the pathlines are integrated
-- with the 16 Euler steps used at deployment. Emits TikZ; run via lualatex.

local SIDE, GAP, W, H = 0.55, 0.08, 3.1, 2.3   -- panel sizes [cm]
local XMIN, XMAX = -2.6, 2.6                   -- action value range
local NSTEP = 16                               -- ODE integration steps
local MX0 = SIDE + GAP                         -- left edge of the field
local RX0 = MX0 + W + GAP                      -- left edge of the data panel

-- demonstrated action distribution: bimodal Gaussian mixture
local wk, mk, sk = {0.6, 0.4}, {1.2, -0.85}, {0.28, 0.33}

local function out(s) tex.sprint(s) end
local function px(t) return MX0 + t * W end
local function py(x) return (x - XMIN) / (XMAX - XMIN) * H end
local function npdf(x, m, var)
  return math.exp(-(x - m)^2 / (2 * var)) / math.sqrt(2 * math.pi * var)
end

-- v*(x, lambda) = E[U^D - U^0 | U^lambda = x]
local function vel(x, t)
  local num, den = 0, 0
  for k = 1, #wk do
    local var = (1 - t)^2 + t^2 * sk[k]^2
    local r = wk[k] * npdf(x, t * mk[k], var)
    num = num + r * (mk[k] + (t * sk[k]^2 - (1 - t)) / var * (x - t * mk[k]))
    den = den + r
  end
  return num / math.max(den, 1e-300)
end

local function erf(x)  -- Abramowitz and Stegun 7.1.26
  local s = x < 0 and -1 or 1
  x = math.abs(x)
  local t = 1 / (1 + 0.3275911 * x)
  local y = ((((1.061405429 * t - 1.453152027) * t + 1.421413741) * t
    - 0.284496736) * t + 0.254829592) * t
  return s * (1 - y * math.exp(-x * x))
end
local function ncdf(x) return 0.5 * (1 + erf(x / math.sqrt(2))) end
local function nppf(p)
  local lo, hi = -8, 8
  for _ = 1, 60 do
    local m = (lo + hi) / 2
    if ncdf(m) < p then lo = m else hi = m end
  end
  return (lo + hi) / 2
end

local function euler(x)
  local xs = {x}
  for i = 0, NSTEP - 1 do
    x = x + vel(x, i / NSTEP) / NSTEP
    xs[#xs + 1] = x
  end
  return xs
end

-- frame and step ticks
out(string.format("\\draw[black!35, line width=0.3pt] (%.4f,0) rectangle (%.4f,%.4f);",
  MX0, MX0 + W, H))
for s = 0, NSTEP do
  local len = (s % 8 == 0) and 0.08 or 0.045
  out(string.format("\\draw[black!60, line width=0.3pt] (%.4f,0) -- ++(0,%.4f);",
    px(s / NSTEP), -len))
end

-- sparse velocity arrows (red pushes up, blue pulls down)
local L = 0.15
for j = 0, 8 do
  local t = (j + 0.5) / 9
  for i = 0, 10 do
    local x = XMIN + (i + 0.5) * (XMAX - XMIN) / 11
    local v = vel(x, t)
    local dx, dy = W, v * H / (XMAX - XMIN)
    local n = math.sqrt(dx * dx + dy * dy)
    dx, dy = dx / n * L, dy / n * L
    local a = math.min(math.abs(v) / 2.5, 1)
    out(string.format(
      "\\draw[%s, opacity=%.2f, line width=0.35pt, -{Stealth[length=0.6mm,width=0.55mm]}] (%.4f,%.4f) -- ++(%.4f,%.4f);",
      v > 0 and "realred" or "simblue", 0.2 + 0.55 * a,
      px(t) - dx / 2, py(x) - dy / 2, dx, dy))
  end
end

-- pathlines from noise quantiles, one dot per Euler step
local NP = 9
for i = 1, NP do
  local xs = euler(nppf((i - 0.5) / NP))
  local pts = {}
  for s = 0, NSTEP do
    pts[#pts + 1] = string.format("(%.4f,%.4f)", px(s / NSTEP), py(xs[s + 1]))
  end
  out("\\draw[black!55, line width=0.4pt] " .. table.concat(pts, " -- ") .. ";")
  for s = 1, NSTEP + 1 do out("\\fill[black!75] " .. pts[s] .. " circle (0.33pt);") end
end

-- one training sample on its straight conditional path
local x0, x1, lam = -1.15, 1.3, 0.55
local xl = (1 - lam) * x0 + lam * x1
out(string.format("\\draw[student, dashed, line width=0.6pt] (%.4f,%.4f) -- (%.4f,%.4f);",
  px(0), py(x0), px(1), py(x1)))
out(string.format("\\fill[student!80!black] (%.4f,%.4f) circle (1pt);", px(0), py(x0)))
out(string.format("\\fill[student!80!black] (%.4f,%.4f) circle (1pt);", px(1), py(x1)))
local dx, dy = W, (x1 - x0) * H / (XMAX - XMIN)
local n = math.sqrt(dx * dx + dy * dy)
out(string.format(
  "\\draw[student!80!black, line width=1pt, -{Stealth[length=1.3mm]}] (%.4f,%.4f) -- ++(%.4f,%.4f);",
  px(lam), py(xl), dx / n * 0.45, dy / n * 0.45))
out(string.format(
  "\\filldraw[fill=white, draw=student!80!black, line width=0.6pt] (%.4f,%.4f) circle (1.4pt);",
  px(lam), py(xl)))
out(string.format(
  "\\node[text=student!60!black, anchor=north west, inner sep=1pt] at (%.4f,%.4f) {$\\mathbf U_t^\\lambda$};",
  px(lam) - 0.02, py(xl) - 0.04))

-- histograms: noise (left) and 16-step Euler push-forward (right)
local NB = 26
local bw, bh = (XMAX - XMIN) / NB, H / NB
local lden, lmax = {}, 0
for b = 1, NB do
  local a = XMIN + (b - 1) * bw
  lden[b] = (ncdf(a + bw) - ncdf(a)) / bw
  lmax = math.max(lmax, lden[b])
end
for b = 1, NB do
  out(string.format(
    "\\filldraw[fill=noise!55, draw=noise!80!black, line width=0.15pt] (%.4f,%.4f) rectangle (%.4f,%.4f);",
    SIDE - lden[b] / lmax * SIDE * 0.95, (b - 1) * bh, SIDE, b * bh))
end

local NS = 4000
local cnt = {}
for b = 1, NB do cnt[b] = 0 end
for i = 1, NS do
  local xT = euler(nppf((i - 0.5) / NS))[NSTEP + 1]
  local b = math.floor((xT - XMIN) / bw) + 1
  if b >= 1 and b <= NB then cnt[b] = cnt[b] + 1 end
end
local rmax = 0
for b = 1, NB do rmax = math.max(rmax, cnt[b] / (NS * bw)) end
local scale = SIDE * 0.95 / rmax
for b = 1, NB do
  out(string.format(
    "\\filldraw[fill=datacol!45, draw=datacol!80!black, line width=0.15pt] (%.4f,%.4f) rectangle (%.4f,%.4f);",
    RX0, (b - 1) * bh, RX0 + cnt[b] / (NS * bw) * scale, b * bh))
end

-- true demonstrated density for comparison
local curve = {}
for i = 0, 100 do
  local x = XMIN + i / 100 * (XMAX - XMIN)
  local d = 0
  for k = 1, #wk do d = d + wk[k] * npdf(x, mk[k], sk[k]^2) end
  curve[#curve + 1] = string.format("(%.4f,%.4f)", RX0 + d * scale, py(x))
end
out("\\draw[black!80, line width=0.45pt, densely dashed] " .. table.concat(curve, " -- ") .. ";")
