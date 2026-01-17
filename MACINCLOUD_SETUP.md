# MacinCloud Setup Guide for Windows Users

This guide helps you develop the iPad app on Windows by using MacinCloud's remote Mac service.

## Why MacinCloud?

- No need to buy a Mac ($1,000+)
- Pay only for development time (~$30-50/month)
- Access latest macOS and Xcode
- Works from any Windows computer
- Cancel anytime

## Setup Process

### 1. Sign Up for MacinCloud

1. Visit **macincloud.com**
2. Choose a plan:
   - **Managed Dedicated Server**: $49-79/month (best for active development)
   - **Pay-as-you-go**: Hourly rate (good for occasional use)
   - **Developer Plan**: $30-40/month (12-month commitment)

3. Server configuration:
   - **OS**: macOS Sonoma or Ventura (latest stable)
   - **Xcode**: Pre-installed (version 15+)
   - **Storage**: 100GB+ recommended

4. Complete registration and payment
5. Wait for server provisioning (usually 10-30 minutes)

### 2. Connect from Windows

#### Option A: Microsoft Remote Desktop (Recommended)

1. **Download Microsoft Remote Desktop**
   - Microsoft Store → Search "Microsoft Remote Desktop"
   - Install the app

2. **Get connection details from MacinCloud**
   - Check your email for server details:
     - Server address (e.g., `macserver.macincloud.com`)
     - Username
     - Password
     - VNC port (usually 5900)

3. **Create connection**
   - Open Microsoft Remote Desktop
   - Click "Add PC"
   - Enter PC name: `server-address:port`
   - User account: Add username/password
   - Display: Full screen recommended
   - Save

4. **Connect**
   - Double-click your saved connection
   - Accept certificate warning (first time)
   - You should see macOS desktop

#### Option B: VNC Viewer (Alternative)

1. Download RealVNC Viewer or TightVNC
2. Connect using: `server:port`
3. Enter credentials

### 3. Configure Your Cloud Mac

Once connected:

#### Install/Update Xcode

```bash
# Open Terminal (Cmd + Space → type "Terminal")

# Check Xcode version
xcodebuild -version

# If Xcode not installed or outdated:
# 1. Open App Store
# 2. Search "Xcode"
# 3. Click "Get" or "Update"
# 4. Wait for download (8-12 GB, takes time)

# Accept Xcode license
sudo xcodebuild -license accept
```

#### Set Up Git

```bash
# Configure Git (use your GitHub credentials)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set up GitHub authentication
# Option 1: HTTPS with Personal Access Token (recommended)
# Create token at: https://github.com/settings/tokens
# Use token as password when prompted

# Option 2: SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"
cat ~/.ssh/id_ed25519.pub
# Copy output and add to GitHub → Settings → SSH Keys
```

#### Clone Repository

```bash
# Navigate to Desktop (or wherever you prefer)
cd ~/Desktop

# Clone your repository
git clone https://github.com/armstri12/clearedtoplan_app.git

# Navigate into project
cd clearedtoplan_app

# Verify files
ls -la
# Should see: QUICKSTART.md, IMPLEMENTATION_PLAN.md, swift-templates/, etc.
```

### 4. Create Xcode Project

Follow QUICKSTART.md:

1. Open Xcode (from Applications or Spotlight)
2. "Create a new Xcode project"
3. Choose iOS → App
4. Configure:
   - Product Name: **ClearedToPlan**
   - Team: Your Apple ID
   - Organization Identifier: com.yourname.clearedtoplan
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Include Tests: ✓
5. Save in `~/Desktop/clearedtoplan_app/` directory

### 5. Import Template Code

1. In Finder, navigate to `~/Desktop/clearedtoplan_app/swift-templates/`
2. Create groups in Xcode Navigator:
   - Right-click ClearedToPlan → New Group → name "Models"
   - Repeat for: ViewModels, Views, Services, Components, App
3. Drag files from swift-templates folders into corresponding Xcode groups
4. Ensure "Copy items if needed" is checked
5. Ensure "Add to targets: ClearedToPlan" is checked

### 6. Build and Test

1. Select iPad simulator: iPad Pro 12.9" (top toolbar)
2. Press **Cmd + B** to build
3. Press **Cmd + R** to run
4. App should launch in simulator

## Development Workflow

### Recommended: Git-based Workflow

**On Windows PC:**
1. Edit Swift files in VS Code with Swift extension
2. Write documentation, plan features
3. Commit and push to GitHub:
   ```bash
   git add .
   git commit -m "Your message"
   git push
   ```

**On MacinCloud:**
1. Pull latest changes:
   ```bash
   cd ~/Desktop/clearedtoplan_app
   git pull
   ```
2. Open project in Xcode
3. Build and test
4. If you made changes in Xcode:
   ```bash
   git add .
   git commit -m "Your message"
   git push
   ```

### Alternative: Direct Remote Desktop

**Pros:**
- Everything in one place
- Use Xcode exclusively
- No sync needed

**Cons:**
- Remote desktop can be laggy
- Smaller screen real estate
- Pay for idle time

## Tips for Success

### Performance Optimization

1. **Use Full Screen Mode**
   - Better experience, less desktop switching
   - In Remote Desktop: click full screen icon

2. **Adjust Resolution**
   - Match your Windows monitor resolution
   - Remote Desktop → Settings → Display

3. **Enable Clipboard Sharing**
   - Copy/paste between Windows and Mac
   - Remote Desktop → Settings → Clipboard

4. **Use Keyboard Shortcuts**
   - Learn Mac shortcuts: Cmd vs Ctrl
   - Cmd + C/V = Copy/Paste
   - Cmd + Space = Spotlight search
   - Cmd + Tab = Switch apps

### Cost Savings

1. **Shut down when not in use**
   - MacinCloud charges for uptime
   - Shut down from macOS: Apple menu → Shut Down
   - Restart when needed from MacinCloud dashboard

2. **Batch your work**
   - Do planning/docs on Windows
   - Use Mac only for Xcode tasks
   - 2-3 hour focused sessions

3. **Use simulators, not real devices**
   - No need for physical iPad during development
   - Simulators are free and fast

### Backup Your Work

1. **Always use Git**
   - Commit frequently
   - Push to GitHub regularly
   - Your work is safe even if Mac crashes

2. **Don't store personal files on cloud Mac**
   - It's temporary infrastructure
   - Can be deleted/reset

## Troubleshooting

### Can't Connect to MacinCloud

- Check email for correct server address and port
- Ensure your firewall allows Remote Desktop
- Try VNC Viewer as alternative
- Contact MacinCloud support

### Xcode Won't Open

- Large download (8-12 GB), be patient
- Check App Store for download progress
- Restart Mac if stuck
- Run from Applications folder, not Launchpad

### Git Authentication Issues

- Use Personal Access Token, not password
- Create at: github.com/settings/tokens
- Permissions needed: repo (all), workflow
- Save token securely (can't view again)

### Simulator Won't Launch

- Xcode → Window → Devices and Simulators
- Delete simulator and download fresh
- Restart Xcode
- Ensure sufficient disk space (20+ GB free)

### Lag/Slow Performance

- Check your internet speed (need 10+ Mbps)
- Close unused Mac applications
- Reduce Remote Desktop quality settings
- Choose server closer to your location (if option available)

## After Development

### When You're Ready to Release

You'll need a **paid Apple Developer account** ($99/year):
1. Sign up at developer.apple.com
2. Add to Xcode (Xcode → Settings → Accounts)
3. Use for App Store submission

### Exiting MacinCloud

When project is complete:
1. Push all code to GitHub (backup!)
2. Cancel MacinCloud subscription
3. Your code is safe in Git
4. Can re-subscribe later for updates

## Cost Estimate

**Development Phase** (2-3 months):
- MacinCloud: ~$50/month × 3 = $150
- Apple Developer: $99/year (when ready to publish)
- **Total: ~$250** vs. $1,000+ for a Mac

**Maintenance** (after launch):
- Only need Mac for updates
- Use pay-as-you-go: ~$5-20/month
- Or pause subscription entirely

## Alternative: Borrow a Mac

If you have access to a friend's Mac:
1. Install Xcode
2. Clone your repo
3. Develop for a few hours
4. Push changes to Git
5. Return their Mac
6. Repeat when needed

## Resources

- MacinCloud: https://www.macincloud.com
- MacinCloud Support: support@macincloud.com
- Apple Developer: https://developer.apple.com
- Xcode Help: Xcode → Help → Xcode Help

---

**Ready to start?** Sign up for MacinCloud and follow this guide!
