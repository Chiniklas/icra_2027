# Policy visualization captures

These figures are real Isaac Sim policy replays rendered with the repository's
`lab232` uv environment. The captures use the Franka-Inspire **Threading V2
Multi** task and its trained M24/M30/M36 policy checkpoint from the sibling
`forgeUltra` worktree:

`checkpoints/franka_threading_v2/multi_nut_z20mm/ForgeTg2.pth`

The Threading V2 task has not yet been merged into this `forgeUltra-franka`
worktree. The captures therefore loaded that task from the sibling worktree and
injected this worktree's publication-camera and visual-randomization helpers.

## Teacher policy: 120-environment overview used in the paper

- Output: `teacher/threading_v2_teacher_120_envs.png`
- Task: `franka_threading_v2:Isaac-Forge-Franka-Threading-V2-Multi-v0`
- Environments: 120 M24/M30/M36 workcells
- Camera eye: `(-14.0, 0.0, 3.0)`
- Camera look-at: `(0.0, 0.0, 0.5)`
- Resolution: `1920 x 1080`
- Visual treatment: white tabletops; task and contact-sensor markers hidden

The `overview-front` camera is a cardinal `-X -> +X` view. Its eye and target
both remain at `Y=0`, and it targets the center of the clone lattice rather
than aiming diagonally across the rows. The pose scales from the number of
environments and `scene.env_spacing`.

## Teacher visual-randomization examples used in the paper

- Outputs:
  - `teacher/randomization_dark.png`
  - `teacher/randomization_warm.png`
  - `teacher/threading_v2_lighting_texture_randomization.png`
  - `teacher/randomization_blue.png`
- Task: `franka_threading_v2:Isaac-Forge-Franka-Threading-V2-Multi-v0`
- Environments: 120 M24/M30/M36 workcells in Isaac's `12 x 10` clone grid
- Environment spacing: `1.6 m` (reduced from the training default of `2.0 m`)
- Camera eye: `(-12.5, -0.8, 2.2)`
- Camera look-at: `(0.0, -0.8, 0.0)`
- Vertical aperture offset: `-3.2`
- Resolution: `1920 x 1080`
- Visual treatment: white tabletops; task markers and all contact-sensor debug
  visualizers hidden

These four captures show the lighting, floor, tabletop, and robot-appearance
variations combined into Fig. 4. Task markers and contact-sensor debug
visualizers are hidden.
