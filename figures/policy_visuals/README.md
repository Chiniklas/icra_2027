# Policy visualization captures

These figures are real Isaac Sim policy replays rendered with the repository's
`lab232` uv environment. The teacher and student captures use the
Franka-Inspire **Threading V2 Multi** task and its trained M24/M30/M36 policy
checkpoint from the sibling `forgeUltra` worktree:

`checkpoints/franka_threading_v2/multi_nut_z20mm/ForgeTg2.pth`

The Threading V2 task has not yet been merged into this `forgeUltra-franka`
worktree. The captures therefore loaded that task from the sibling worktree and
injected this worktree's publication-camera and visual-randomization helpers.

## Teacher policy: 120-environment podium overview

- Output: `teacher/threading_v2_teacher_120_podium.png`
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

## Teacher policy: 120-environment camera-test-X view

- Output: `teacher/threading_v2_teacher_120_camera_test_x.png`
- Task: `franka_threading_v2:Isaac-Forge-Franka-Threading-V2-Multi-v0`
- Environments: 120 M24/M30/M36 workcells in Isaac's `12 x 10` clone grid
- Environment spacing: `1.6 m` (reduced from the training default of `2.0 m`)
- Camera eye: `(-12.5, -0.8, 2.2)`
- Camera look-at: `(0.0, -0.8, 0.0)`
- Vertical aperture offset: `-3.2`
- Resolution: `1920 x 1080`
- Visual treatment: white tabletops; task markers and all contact-sensor debug
  visualizers hidden

This is the 120-environment equivalent of
`teacher/threading_v2_camera_test_x.png`. Its eye is approximately 0.5 m above
the robots and uses a flatter, roughly 10-degree downward angle. The `Y=-0.8`
alignment looks through a populated workcell column in the compressed grid
instead of the empty aisle at its center. A vertical lens shift removes the
otherwise empty sky band without steepening the optical axis. Reusing the
nine-environment eye position `(-6.0, 0.0, 2.0)` literally would place the
camera inside the 120-environment lattice and crop the nearest robots.

## Student-side visual-randomization preview

- Outputs:
  - `student/all_randomized/view_01.png` through `view_04.png`, plus
    `student/all_randomized/montage.png`
  - `student/no_robot_randomization/view_01.png` through `view_04.png`, plus
    `student/no_robot_randomization/montage.png`
  - `student/no_floor_or_robot_randomization/view_01.png` through
    `view_04.png`, plus
    `student/no_floor_or_robot_randomization/montage.png`
- Task: `franka_threading_v2:Isaac-Forge-Franka-Threading-V2-Multi-v0`
- Environments: one isolated M24 workcell replayed with the multi-nut teacher
- Layout: four real replay frames in a `2 x 2` montage
- Camera eye: `(-1.6, 0.0, 0.6)` (0.5 m below the preceding student capture)
- Camera look-at: `(0.55, 0.0, 0.45)`
- Vertical aperture offset: `0.0`
- Source-frame resolution: `1920 x 1080`
- Debug treatment: task markers and all contact-sensor visualizers hidden

All three configurations retain dome-light and tabletop randomization. The first
also randomizes the shared floor and whole robot. The second keeps the robot's
authored white-and-black appearance while randomizing the floor. The third
keeps both the authored robot appearance and default grid floor. Each
subdirectory contains the four full-resolution source images used to build its
montage.

The camera is reasserted after task construction because Threading V2 replaces
the viewport while building its scene. The lower front-on pose retains the
complete robot, threading hardware, and tabletop in every panel.

There is currently no Franka-Inspire flow-matching checkpoint in either
worktree. The montage therefore documents the Threading V2 student visual
training distribution using deterministic Threading V2 teacher playback; it
must not be labeled as a flow-policy rollout.
