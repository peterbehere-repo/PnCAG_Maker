# PnCAG_Maker — Point & Click Adventure Game Maker

Multi-project workspace for point-and-click adventure games built with
[Godot 4.6](https://godotengine.org) + [Popochiu 2.1](https://github.com/Popochiu/).

## Live builds (GitHub Pages)

| Game | URL |
|------|-----|
| DetectiveDemo | https://peterbehere-repo.github.io/PnCAG_Maker/DetectiveDemo/ |

## Repo layout

```
PnCAG_Maker/
├── projects/            # one folder per game
│   └── <game>/
│       ├── game/        # Godot source project (addon + scenes + scripts)
│       └── build/
│           └── web/     # exported web build (auto-deployed to gh-pages)
├── .github/workflows/   # Pages deploy automation
└── README.md
```

## Workflow

- Edit the game in `projects/<game>/game/`
- Push to `main` → GitHub Actions re-exports the web build → deploys to `gh-pages`
- Every project gets a live URL under `https://peterbehere-repo.github.io/PnCAG_Maker/<game>/`

*Authoring happens in the Rool VM (`/rool-drive/GameDev/Projects/`); pushes from the VM keep this repo in sync.*
