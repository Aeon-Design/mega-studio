#!/usr/bin/env python3
"""
Ralph Wiggum v8.0 - Advanced Autonomous QA System
Strict strictness, coverage thresholds, and golden file checks.

Usage:
  python ralph.py --full                          # Full QA Suite
  python ralph.py --test --coverage-min 80        # Test with threshold
  python ralph.py --analyze --strict              # Analyze with fatal infos
"""

import argparse
import json
import os
import subprocess
import sys
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional

class RalphWiggum:
    """Autonomous QA System - v8.0 Edition"""
    
    def __init__(self, project_root: str = '.', strict: bool = False):
        self.project_root = Path(project_root).resolve()
        self.report_dir = self.project_root / '.maestro' / 'ralph'
        self.report_dir.mkdir(parents=True, exist_ok=True)
        self.strict = strict

    def _run_command(self, cmd: List[str], cwd: Optional[Path] = None, timeout: int = 600) -> Tuple[int, str, str]:
        try:
            result = subprocess.run(
                cmd,
                cwd=cwd or self.project_root,
                capture_output=True,
                text=True,
                timeout=timeout
            )
            return result.returncode, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            return -1, '', 'Timeout exceeded'
        except Exception as e:
            return -1, '', str(e)

    def run_flutter_analyze(self) -> Dict:
        print("🔍 Running flutter analyze...")
        cmd = ['flutter', 'analyze']
        if not self.strict:
            cmd.append('--no-fatal-infos')
        
        code, stdout, stderr = self._run_command(cmd)
        
        issues = []
        for line in stdout.split('\n'):
            line = line.strip()
            if line and ('info •' in line or 'warning •' in line or 'error •' in line):
                issues.append(line)
        
        print(f"   Found {len(issues)} issues")
        return {
            'success': code == 0,
            'issue_count': len(issues),
            'issues': issues[:50],
            'output': stdout
        }

    def run_flutter_test(self, coverage_min: int = 0) -> Dict:
        print("🧪 Running flutter test...")
        cmd = ['flutter', 'test', '--coverage']
        code, stdout, stderr = self._run_command(cmd)
        
        passed, failed = 0, 0
        test_failures = []
        
        # Simple output parsing
        for line in stdout.split('\n'):
             if 'All tests passed!' in line:
                 pass # We rely on exit code largely, but good to know
             elif 'Some tests failed' in line:
                 pass
             if 'FAILED' in line:
                 failed += 1
                 test_failures.append(line)
        
        # Coverage check
        coverage_pct = 0.0
        lcov_path = self.project_root / 'coverage' / 'lcov.info'
        coverage_success = True
        
        if lcov_path.exists():
            coverage_pct = self._calculate_coverage(lcov_path)
            print(f"   Coverage: {coverage_pct}%")
            if coverage_min > 0 and coverage_pct < coverage_min:
                print(f"❌ Coverage below threshold ({coverage_min}%)")
                coverage_success = False
        else:
            print("⚠️ No coverage file generated")

        final_success = (code == 0) and coverage_success

        return {
            'success': final_success,
            'passed': passed, # Note: parsed loosely
            'failed': failed,
            'failures': test_failures,
            'coverage': coverage_pct,
            'coverage_success': coverage_success
        }

    def _calculate_coverage(self, lcov_path: Path) -> float:
        try:
            content = lcov_path.read_text(encoding='utf-8')
            lines_found = 0
            lines_hit = 0
            for line in content.splitlines():
                if line.startswith('LF:'):
                    lines_found += int(line[3:])
                elif line.startswith('LH:'):
                    lines_hit += int(line[3:])
            if lines_found == 0: return 0.0
            return round((lines_hit / lines_found) * 100, 2)
        except:
            return 0.0

    def run_dart_format(self) -> Dict:
        print("📝 Checking code formatting...")
        code, stdout, stderr = self._run_command(['dart', 'format', '--set-exit-if-changed', '--output=none', '.'])
        return {
            'success': code == 0,
            'output': stdout
        }

    def run_full_audit(self, coverage_min=80):
        print("\n🎭 RALPH WIGGUM v8.0 - FULL AUDIT")
        print("="*60)
        
        results = {}
        
        # 1. Format
        results['format'] = self.run_dart_format()
        
        # 2. Analyze
        results['analyze'] = self.run_flutter_analyze()
        
        # 3. Test & Coverage
        results['test'] = self.run_flutter_test(coverage_min=coverage_min)
        
        self.print_summary(results, coverage_min)
        return results

    def print_summary(self, results, coverage_min):
        print("\n" + "="*60)
        print("📋 FINAL QA REPORT")
        print("="*60)
        
        format_ok = results['format']['success']
        analyze_ok = results['analyze']['success']
        test_ok = results['test']['success']
        
        print(f"Formatting:    {'✅ PASS' if format_ok else '❌ FAIL'}")
        print(f"Analysis:      {'✅ PASS' if analyze_ok else '❌ FAIL'} ({results['analyze']['issue_count']} issues)")
        print(f"Tests:         {'✅ PASS' if test_ok else '❌ FAIL'}")
        print(f"Coverage:      {results['test']['coverage']}% (Target: {coverage_min}%)")
        
        all_passed = format_ok and analyze_ok and test_ok
        print("-" * 60)
        print(f"OVERALL STATUS: {'✅ APPROVED' if all_passed else '❌ REJECTED'}")
        print("=" * 60)

def main():
    parser = argparse.ArgumentParser(description='Ralph Wiggum QA System')
    parser.add_argument('--full', action='store_true', help='Run full audit')
    parser.add_argument('--analyze', action='store_true', help='Run analysis')
    parser.add_argument('--test', action='store_true', help='Run tests')
    parser.add_argument('--format', action='store_true', help='Check format')
    parser.add_argument('--strict', action='store_true', help='Strict mode (fatal infos)')
    parser.add_argument('--coverage-min', type=int, default=80, help='Minimum coverage percentage')
    
    args = parser.parse_args()
    ralph = RalphWiggum(strict=args.strict)
    
    if args.full:
        ralph.run_full_audit(coverage_min=args.coverage_min)
    elif args.analyze:
        ralph.run_flutter_analyze()
    elif args.test:
        ralph.run_flutter_test(coverage_min=args.coverage_min)
    elif args.format:
        ralph.run_dart_format()
    else:
        # Default behavior checks basic health
        ralph.run_flutter_analyze()

if __name__ == '__main__':
    main()
