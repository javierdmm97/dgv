---
name: agent-discipline
description: CRITICAL - Stop generating unnecessary files and documentation. Only create what is explicitly asked for.
---

# 🛑 AGENT DISCIPLINE

## CRITICAL RULE

**DO NOT generate 50 markdown files, documentation, or "helpful" extras unless explicitly asked.**

### What This Means

- ❌ User asks: "translate .claude to Kiro" → DO NOT create TRANSLATION_PLAN.md, README.md, SUMMARY.md, etc.
- ✅ User asks: "translate .claude to Kiro" → Create ONLY the hooks, steering, and skills needed
- ❌ User asks: "update checkpoint timer" → DO NOT create 7 new documentation files
- ✅ User asks: "update checkpoint timer" → Update ONLY the files mentioned

### The Pattern to Avoid

1. User asks for X
2. You create X
3. You also create Y, Z, AA, AB, AC... "to be helpful"
4. User says "stop generating 50 files"
5. Repeat

### What to Do Instead

1. User asks for X
2. You create ONLY X
3. If you think something else is needed, ASK first
4. Wait for explicit approval before creating anything extra

### Examples

**WRONG:**
```
User: "Create hooks for the project"
You: Creates 5 hooks + TRANSLATION_PLAN.md + README.md + SUMMARY.txt + CHECKLIST.md
User: "Stop!"
```

**RIGHT:**
```
User: "Create hooks for the project"
You: Creates 5 hooks
User: "Can you also create a README?"
You: Creates README.md
```

### When in Doubt

- Ask: "Should I also create X?"
- Don't assume
- Don't be "helpful" by creating extras
- Respect the user's time and workspace

---

**Remember:** Less is more. Discipline over enthusiasm.
