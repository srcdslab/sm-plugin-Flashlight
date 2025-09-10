# Copilot Instructions for sm-plugin-Flashlight

## Repository Overview

This repository contains a SourcePawn plugin for SourceMod that replaces Counter-Strike: Global Offensive's `+lookatweapon` command with a toggleable flashlight functionality. The plugin allows players to toggle their flashlight using either the original key binding or a custom command, with configurable sound effects and behavior.

**Key Features:**
- Replaces `+lookatweapon` with flashlight toggle
- Configurable sound effects for flashlight activation
- Custom `sm_flashlight` command for manual toggling
- ConVar-based configuration system
- Support for dead player flashlight usage

## Project Structure

```
addons/sourcemod/scripting/
├── Flashlight.sp              # Main plugin source code

.github/
├── workflows/
│   └── ci.yml                 # GitHub Actions CI/CD pipeline
└── dependabot.yml             # Dependency management

sourceknight.yaml              # Build configuration for sourceknight
.gitignore                     # Git ignore rules
```

## Technical Environment

- **Language**: SourcePawn
- **Platform**: SourceMod 1.11.0+ (currently using 1.11.0-git6917)
- **Compiler**: SourcePawn compiler via sourceknight build system
- **Build Tool**: sourceknight (not standard spcomp)
- **Target**: Source engine games (primarily CS:GO)

## Build System

This project uses **sourceknight** as its build system, not the standard SourceMod compiler directly.

### Build Configuration
The build is configured in `sourceknight.yaml`:
- Dependencies are automatically downloaded (SourceMod 1.11.0-git6917)
- Output directory: `/addons/sourcemod/plugins`
- Target: `Flashlight` (produces `Flashlight.smx`)

### Local Development
```bash
# Install sourceknight if not available
# Build the plugin
sourceknight build
```

### CI/CD Pipeline
- Automated builds on push, PR, and manual dispatch
- Uses `maxime1907/action-sourceknight@v1` action
- Creates releases automatically from tags and main/master branch
- Packages built plugins for distribution

## Code Style & Standards

### Current Code Analysis
The existing code follows these patterns:
- Uses `#pragma semicolon 1` and `#pragma newdecls required`
- Mix of old Handle syntax and newer practices
- Global variables prefixed with `g` but inconsistent naming (e.g., `gH_LAW`)
- CamelCase for some variables, unclear consistency

### Recommended Improvements for New Code
When modifying this plugin, follow these guidelines:

1. **Variable Naming**:
   - Global variables: `g_PascalCase` (e.g., `g_FlashlightSound`)
   - Local variables: `camelCase`
   - ConVar handles: `g_ConVar_Name`

2. **Modern SourceMod Practices**:
   - Use `ConVar` type instead of `Handle` for ConVars
   - Use `delete` for cleanup instead of `CloseHandle()`
   - Prefer methodmaps over function-based APIs where available

3. **Code Organization**:
   - Group related ConVars together
   - Add proper error handling for all API calls
   - Use descriptive function and variable names

## Common Development Tasks

### Adding New ConVars
```sourcepawn
// Declare global ConVar
ConVar g_ConVar_NewSetting;

// In OnPluginStart()
g_ConVar_NewSetting = CreateConVar("sm_flashlight_newsetting", "1", 
    "Description of the new setting", FCVAR_NONE, true, 0.0, true, 1.0);
HookConVarChange(g_ConVar_NewSetting, ConVarChanged);

// Handle changes in ConVarChanged callback
if (cvar == g_ConVar_NewSetting)
    // Handle the change
```

### Adding New Commands
```sourcepawn
// In OnPluginStart()
RegConsoleCmd("sm_newcommand", Command_NewCommand, "Description");

// Command callback
public Action Command_NewCommand(int client, int args)
{
    // Validate client
    if (!IsClientInGame(client) || !IsPlayerAlive(client))
        return Plugin_Handled;
    
    // Command logic here
    return Plugin_Handled;
}
```

### Sound Management
The plugin includes sound precaching and download management:
- Sounds are precached in `UpdateSound()` and `OnMapStart()`
- Custom sounds are added to downloads table
- Default sound: `items/flashlight1.wav`

## Plugin Architecture

### Core Components
1. **ConVar System**: Manages plugin configuration
2. **Command Listeners**: Hooks `+lookatweapon` and handles custom commands  
3. **Sound System**: Manages flashlight sound effects
4. **Flashlight Toggle**: Core functionality using entity properties

### Key Functions
- `ToggleFlashlight(int client)`: Main flashlight toggle logic
- `UpdateSound()`: Handles sound configuration changes
- `ConVarChanged()`: Manages ConVar change events

### Entity Property Usage
The plugin uses `m_fEffects` entity property to control flashlight:
```sourcepawn
SetEntProp(client, Prop_Send, "m_fEffects", GetEntProp(client, Prop_Send, "m_fEffects") ^ 4);
```

## Testing Guidelines

### Manual Testing Checklist
1. **Basic Functionality**:
   - [ ] `+lookatweapon` toggles flashlight (when enabled)
   - [ ] `sm_flashlight` command works
   - [ ] Flashlight persists across respawns appropriately

2. **ConVar Testing**:
   - [ ] `sm_flashlight_lookatweapon` enables/disables hook
   - [ ] `sm_flashlight_return` controls command blocking
   - [ ] `sm_flashlight_sound` changes work correctly
   - [ ] `sm_flashlight_sound_all` affects sound broadcasting

3. **Edge Cases**:
   - [ ] Dead player flashlight functionality
   - [ ] Sound effects work for all/individual players
   - [ ] Custom sound files are downloaded properly

### Server Testing
Test on a Source engine server with:
- Multiple players
- Map changes
- Plugin reload scenarios

## Debugging Common Issues

### Build Failures
- Check sourceknight installation and version
- Verify `sourceknight.yaml` configuration
- Ensure SourceMod dependency is accessible

### Runtime Issues
- Use `sm plugins list` to verify plugin loaded
- Check `sm_flashlight_*` ConVars are set correctly
- Verify `mp_flashlight` is enabled on the server
- Check SourceMod error logs for API call failures

### Sound Problems
- Ensure sound files exist in correct paths
- Check if custom sounds are being downloaded
- Verify sound precaching in `OnMapStart()`

## Contributing Guidelines

### Before Making Changes
1. Test current functionality on a development server
2. Understand the existing ConVar system
3. Check if changes affect backward compatibility

### Code Review Focus Areas
- Memory management (proper use of `delete`)
- Error handling for all SourceMod API calls
- ConVar change handling
- Sound system interactions
- Client validation in commands

### Performance Considerations
- Minimize operations in frequently called functions (`OnPlayerRunCmd`, `OnSound`)
- Cache ConVar values instead of repeated `GetConVarInt()` calls
- Be mindful of sound broadcasting to all clients

## Version Management

- Plugin version is defined in the `myinfo` structure
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Update version in plugin info when making releases
- CI automatically creates releases from git tags

## Dependencies

- **Required**: SourceMod 1.11.0+ 
- **Includes**: `sourcemod`, `sdktools`
- **ConVars**: Depends on `mp_flashlight` server ConVar
- **Build**: sourceknight build system

## Useful Resources

- [SourceMod API Documentation](https://sm.alliedmods.net/new-api/)
- [SourcePawn Language Reference](https://wiki.alliedmods.net/SourcePawn)
- [sourceknight Documentation](https://github.com/maxime1907/sourceknight)