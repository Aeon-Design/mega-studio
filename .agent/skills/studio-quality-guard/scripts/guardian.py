#!/usr/bin/env python3
import os
import sys
import json
import subprocess
import argparse
import re
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any, Set

class StudioQualityGuardian:
    """Advanced QA, L10n & Diagnostic Orchestrator"""
    
    def __init__(self, project_path: str):
        self.project_path = Path(project_path).resolve()
        self.audit_dir = self.project_path / '.studio' / 'audit'
        self.audit_dir.mkdir(parents=True, exist_ok=True)
        self.timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        
    def _run_cmd(self, cmd: List[str]) -> Dict[str, Any]:
        """Runs a command and returns the result"""
        try:
            process = subprocess.run(
                cmd, 
                cwd=self.project_path, 
                capture_output=True, 
                text=True, 
                timeout=600  # 10 minutes
            )
            return {
                "success": process.returncode == 0,
                "stdout": process.stdout,
                "stderr": process.stderr,
                "exit_code": process.returncode
            }
        except Exception as e:
            return {"success": False, "stdout": "", "stderr": str(e), "exit_code": -process.returncode if 'process' in locals() else -1}

    def scan_features(self) -> List[str]:
        """Discovers all features in lib/features"""
        features_path = self.project_path / 'lib' / 'features'
        if not features_path.exists():
            return []
        return [f.name for f in features_path.iterdir() if f.is_dir()]

    def scan_l10n(self) -> Dict[str, Any]:
        """Audits localization files for missing keys and consistency"""
        l10n_dir = self.project_path / 'lib' / 'l10n'
        if not l10n_dir.exists():
            return {"success": False, "message": "l10n directory not found"}

        arb_files = list(l10n_dir.glob('*.arb'))
        if not arb_files:
            return {"success": False, "message": "No .arb files found"}

        # Use app_en.arb as baseline
        baseline_file = l10n_dir / 'app_en.arb'
        if not baseline_file.exists():
            baseline_file = arb_files[0]

        try:
            baseline_data = json.loads(baseline_file.read_text(encoding='utf-8'))
            baseline_keys = {k for k in baseline_data.keys() if not k.startswith('@')}
        except Exception as e:
            return {"success": False, "message": f"Failed to parse baseline: {e}"}

        audit_results = {"files": {}, "missing_total": 0}
        for arb in arb_files:
            if arb == baseline_file: continue
            try:
                data = json.loads(arb.read_text(encoding='utf-8'))
                keys = {k for k in data.keys() if not k.startswith('@')}
                missing = baseline_keys - keys
                audit_results["files"][arb.name] = {
                    "missing_keys": list(missing),
                    "count": len(missing)
                }
                audit_results["missing_total"] += len(missing)
            except:
                audit_results["files"][arb.name] = {"error": "JSON parse error"}

        return audit_results

    def scan_visual_integrity(self) -> Dict[str, Any]:
        """Checks for 'visual noise' (print statements) and asset health"""
        print_count = 0
        files_with_prints = []
        
        lib_path = self.project_path / 'lib'
        for root, _, files in os.walk(lib_path):
            for file in files:
                if file.endswith('.dart'):
                    try:
                        path = Path(root) / file
                        content = path.read_text(encoding='utf-8')
                        matches = re.findall(r'\bprint\(', content)
                        if matches:
                            print_count += len(matches)
                            files_with_prints.append(str(path.relative_to(self.project_path)))
                    except:
                        pass
        
        return {
            "print_statements": print_count,
            "noisy_files": files_with_prints[:15],
            "score_impact": max(0, 20 - (print_count // 5)) # Impact on score
        }

    def run_health_check(self) -> Dict[str, Any]:
        """Performs Analyze, Test, and Build checks"""
        results = {}
        # Avoid running analyze/test twice by checking if caller already did it
        # But for standalone, we run it.
        results['analyze'] = self._run_cmd(['flutter', 'analyze', '--no-fatal-infos'])
        results['test'] = self._run_cmd(['flutter', 'test', '--no-pub'])
        return results

    def generate_report(self, health: Dict, l10n: Dict, visual: Dict, features: List[str]):
        """Generates the Studio Quality Audit Report"""
        report_file = self.audit_dir / f"audit_report_{self.timestamp}.md"
        latest_link = self.audit_dir / "latest_report.md"
        
        # Calculate scores
        analyze_score = 30 if health['analyze']['success'] else 0
        test_score = 30 if health['test']['success'] else 0
        l10n_score = max(0, 20 - (l10n.get('missing_total', 0) // 10))
        visual_score = visual.get('score_impact', 20)
        
        total_score = analyze_score + test_score + l10n_score + visual_score

        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(f"# 🛡️ Studio Quality Audit Report\n\n")
            f.write(f"**Date:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"**Total Quality Score:** `{total_score}/100`\n\n")

            f.write("## 🏗️ 1. Infrastructure Health\n")
            f.write(f"| Metric | Status | Score |\n")
            f.write(f"| :--- | :--- | :--- |\n")
            f.write(f"| Static Analysis | {'✅ PASS' if health['analyze']['success'] else '❌ FAIL'} | {analyze_score}/30 |\n")
            f.write(f"| Functional Tests | {'✅ PASS' if health['test']['success'] else '❌ FAIL'} | {test_score}/30 |\n")
            f.write(f"| Localization Integrity | {'✅' if l10n.get('missing_total', 0) == 0 else '⚠️'} | {l10n_score}/20 |\n")
            f.write(f"| Visual/Performance Noise | {'✅' if visual['print_statements'] < 10 else '⚠️'} | {visual_score}/20 |\n\n")

            f.write("## 🌍 2. Language & Localization Audit\n")
            f.write(f"- Total missing keys across all locales: `{l10n.get('missing_total', 0)}`\n")
            if l10n.get('missing_total', 0) > 0:
                f.write("### Missing Keys Example:\n")
                for fname, fmeta in l10n['files'].items():
                    if fmeta.get('count', 0) > 0:
                        f.write(f"- **{fname}**: `{fmeta['count']}` keys missing (e.g., `{', '.join(fmeta['missing_keys'][:3])}...`)\n")
            f.write("\n")

            f.write("## 👁️ 3. Visual & Code Noise\n")
            f.write(f"- Detected `print()` statements: `{visual['print_statements']}`\n")
            if visual['noisy_files']:
                f.write("> [!TIP]\n")
                f.write("> Use a proper logger or `debugPrint()` instead of `print()` to keep the console clean and professional.\n")
            f.write("\n")

            f.write("## 🛠️ 4. Actionable Fix Plan for @/debugger\n")
            if not health['analyze']['success']:
                f.write("### 🟥 Phase 1: Clean Analysis Errors\n")
                f.write(f"Analyze reported issues. Run `flutter analyze` to see full list.\n")
                f.write("```bash\nflutter analyze\n```\n")
            if not health['test']['success']:
                f.write("### 🟧 Phase 2: Fix Regression Tests\n")
                f.write("Some unit/widget tests are failing. Inspect the failed tests in `test/`.\n")
            if l10n.get('missing_total', 0) > 0:
                f.write("### 🟨 Phase 3: Synchronize Localization\n")
                f.write("Sync the missing keys from `app_en.arb` to other locales.\n")

        # Update symlink
        if os.path.exists(latest_link): os.remove(latest_link)
        with open(latest_link, 'w', encoding='utf-8') as f:
            f.write(f"See [audit_report_{self.timestamp}.md](file:///{report_file.as_posix()})")
            
        return report_file, total_score

def main():
    parser = argparse.ArgumentParser(description='Studio Quality Guardian Advanced')
    parser.add_argument('--project', default='.', help='Project root path')
    parser.add_argument('--full-audit', action='store_true', help='Full audit')
    
    args = parser.parse_args()
    guardian = StudioQualityGuardian(args.project)
    
    features = guardian.scan_features()
    health = guardian.run_health_check()
    l10n = guardian.scan_l10n()
    visual = guardian.scan_visual_integrity()
    
    report_path, score = guardian.generate_report(health, l10n, visual, features)
    print(f"Audit Complete. Score: {score}. Report: {report_path}")

if __name__ == '__main__':
    main()
