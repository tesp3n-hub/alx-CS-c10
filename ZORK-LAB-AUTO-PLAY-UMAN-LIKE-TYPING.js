// ZORK LAB - AUTO-PLAY WITH HUMAN-LIKE TYPING
// Commands will be typed character-by-character like a real human
//if you want test normally : type  commands but After "use admin badge" in developer type => gameState.biometricScannersDisabled = true;
// Paste this entire script into the browser console (F12)

const commands = [
    "go east",
    "take ladder",
    "take cleaning supplies",
    "go west",
    "climb wall",
    "enter 1357",
    "examine map",
    "go north",
    "wait",
    "use computer",
    "enter CamW4tch!",
    "disable cameras",
    "disable cameras",
    "disable cameras",
    "take security uniform",
    "take security override card",
    "go south",
    "go east",
    "take coffee cup",
    "take employee directory",
    "go west",
    "go north",
    "disable cameras",
    "disable cameras",
    "go east",
    "use computer",
    "enter Rex2025",
    "take admin badge",
    "go south",
    "enter 737837",
    "go south",
    "take manual",
    "go east",
    "search insurance",
    "take master key",
    "go north",
    "use master key",
    "enter 9876",
    "enter 102382",
    "go south",
    "go west",
    "go north",
    "go west",
    "use access card",
    "go west",
    "take vault schematic",
    "offer coffee",
    "use admin badge", 
    "go south",
    "use security override card",
    "enter 04131986",
    "open vault",
    "take gold"
];

console.log("%c🎮 ZORK LAB AUTO-PLAY WITH HUMAN TYPING", "color: cyan; font-size: 18px; font-weight: bold;");
console.log(`Total commands: ${commands.length}`);

// Function to type text character by character like a human
function typeCommand(text, input, callback) {
    let charIndex = 0;
    input.value = "";
    
    const typingInterval = setInterval(() => {
        if (charIndex < text.length) {
            input.value += text[charIndex];
            input.dispatchEvent(new Event('input', { bubbles: true }));
            charIndex++;
        } else {
            clearInterval(typingInterval);
            callback();
        }
    }, 80 + Math.random() * 40); // Random typing speed: 80-120ms per character
}

let commandIndex = 0;

function executeNextCommand() {
    if (commandIndex >= commands.length) {
        console.log("%c🏆 HEIST COMPLETE! YOU GOT THE GOLD! 🏆", "color: gold; font-size: 24px; font-weight: bold;");
        return;
    }
    
    // CRITICAL: After "use admin badge" (index 47), disable biometric scanners
    if (commandIndex === 47) {
        setTimeout(() => {
            if (typeof gameState !== 'undefined') {
                gameState.biometricScannersDisabled = true;
                console.log("%c✅ Biometric scanners disabled!", "color: lime; font-weight: bold;");
            }
        }, 600);
    }
    
    const input = document.querySelector('#command-input') || 
                  document.querySelector('input[placeholder*="command"]') ||
                  document.querySelector('input[placeholder*="Enter"]') ||
                  document.querySelector('input');
    const btn = document.querySelector('button');
    
    if (input && btn) {
        const currentCommand = commands[commandIndex];
        console.log(`[${commandIndex + 1}/${commands.length}] Typing: ${currentCommand}`);
        
        // Type the command character by character
        typeCommand(currentCommand, input, () => {
            // After typing is complete, wait a moment then click submit
            setTimeout(() => {
                btn.click();
                
                // Wait before next command (human think time)
                setTimeout(() => {
                    commandIndex++;
                    executeNextCommand();
                }, 800 + Math.random() * 400); // Random delay: 800-1200ms between commands
            }, 300 + Math.random() * 200); // Random delay before submit: 300-500ms
        });
    }
}

// Start the automation
executeNextCommand();

