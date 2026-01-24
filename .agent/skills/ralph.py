#!/usr/bin/env python3
"""
Ralph Wiggum - Autonomous QA System for Flutter
Maestro'dan adapte edilmiş otonom debug ve test döngüsü.

Kullanım:
  python ralph.py --iterations 3 --project /path/to/flutter/project
  python ralph.py --analyze                 # Kod analizi
  python ralph.py --test                    # Test çalıştır
  python ralph.py --lint                    # Lint kontrolü

Ralph'ın 4 Sütunu:
1. Test Execution - Testleri çalıştır
2. Lint Analysis - Statik analiz
3. Build Verification - Build kontrolü
4. Evidence Collection - Kanıt topla
"""

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Optional

class RalphWiggum:
    """Autonomous QA System - Flutter Edition"""
    
    def __init__(self, project_root: str = '.'):
        self.project_root = Path(project_root).resolve()
        self.report_dir = self.project_root / '.maestro' / 'ralph'
        self.report_dir.mkdir(parents=True, exist_ok=True)
    
    def _run_command(self, cmd: List[str], cwd: Optional[Path] = None) -> Tuple[int, str, str]:
        """Komutu çalıştır ve sonucu döndür"""
        try:
            result = subprocess.run(
                cmd,
                cwd=cwd or self.project_root,
                capture_output=True,
                text=True,
                timeout=300  # 5 dakika
            )
            return result.returncode, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            return -1, '', 'Timeout exceeded'
        except Exception as e:
            return -1, '', str(e)
    
    def _get_timestamp(self) -> str:
        return datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    def check_flutter_project(self) -> bool:
        """Flutter projesi mi kontrol et"""
        pubspec = self.project_root / 'pubspec.yaml'
        return pubspec.exists()
    
    def run_flutter_analyze(self) -> Dict:
        """flutter analyze çalıştır"""
        print("🔍 Running flutter analyze...")
        
        code, stdout, stderr = self._run_command(['flutter', 'analyze', '--no-fatal-infos'])
        
        # Parse results
        issues = []
        for line in stdout.split('\n'):
            line = line.strip()
            if line and ('info •' in line or 'warning •' in line or 'error •' in line):
                issues.append(line)
        
        return {
            'success': code == 0,
            'issue_count': len(issues),
            'issues': issues[:20],  # İlk 20 issue
            'raw_output': stdout[:2000]
        }
    
    def run_flutter_test(self) -> Dict:
        """flutter test çalıştır"""
        print("🧪 Running flutter test...")
        
        code, stdout, stderr = self._run_command(['flutter', 'test', '--coverage'])
        
        # Parse results
        tests_passed = 0
        tests_failed = 0
        test_errors = []
        
        for line in stdout.split('\n'):
            if 'All tests passed!' in line:
                tests_passed = -1  # Hepsini geçti
            elif 'tests passed' in line.lower():
                # "00:05 +42: All tests passed!" formatı
                import re
                match = re.search(r'\+(\d+)', line)
                if match:
                    tests_passed = int(match.group(1))
            elif 'FAILED' in line or 'failed' in line:
                tests_failed += 1
                test_errors.append(line)
        
        # Coverage
        coverage = None
        lcov_path = self.project_root / 'coverage' / 'lcov.info'
        if lcov_path.exists():
            coverage = self._parse_coverage(lcov_path)
        
        return {
            'success': code == 0,
            'passed': tests_passed,
            'failed': tests_failed,
            'coverage': coverage,
            'errors': test_errors[:10],
            'raw_output': stdout[:2000]
        }
    
    def _parse_coverage(self, lcov_path: Path) -> float:
        """LCOV dosyasından coverage hesapla"""
        try:
            content = lcov_path.read_text()
            lines_hit = 0
            lines_found = 0
            
            for line in content.split('\n'):
                if line.startswith('LH:'):
                    lines_hit += int(line[3:])
                elif line.startswith('LF:'):
                    lines_found += int(line[3:])
            
            if lines_found > 0:
                return round((lines_hit / lines_found) * 100, 2)
        except:
            pass
        return None
    
    def run_flutter_build(self, target: str = 'apk') -> Dict:
        """flutter build çalıştır (debug mode)"""
        print(f"🔨 Running flutter build {target} --debug...")
        
        cmd = ['flutter', 'build', target, '--debug']
        code, stdout, stderr = self._run_command(cmd)
        
        return {
            'success': code == 0,
            'target': target,
            'output': stdout[:1000] if code == 0 else stderr[:1000]
        }
    
    def run_dart_format_check(self) -> Dict:
        """dart format kontrolü"""
        print("📝 Checking dart format...")
        
        code, stdout, stderr = self._run_command(
            ['dart', 'format', '--set-exit-if-changed', '--output=none', 'lib']
        )
        
        unformatted = []
        if code != 0:
            for line in stdout.split('\n'):
                if line.strip() and 'Changed' in line:
                    unformatted.append(line.strip())
        
        return {
            'success': code == 0,
            'unformatted_count': len(unformatted),
            'unformatted_files': unformatted[:10]
        }
    
    def collect_evidence(self, results: Dict) -> Dict:
        """Kanıt topla ve raporla"""
        timestamp = self._get_timestamp()
        
        evidence = {
            'timestamp': timestamp,
            'project': str(self.project_root),
            'results': results,
            'summary': {
                'all_passed': all([
                    results.get('analyze', {}).get('success', False),
                    results.get('test', {}).get('success', False),
                    results.get('format', {}).get('success', False),
                ]),
                'issues_found': results.get('analyze', {}).get('issue_count', 0),
                'tests_passed': results.get('test', {}).get('passed', 0),
                'tests_failed': results.get('test', {}).get('failed', 0),
                'coverage': results.get('test', {}).get('coverage'),
            }
        }
        
        # Raporu kaydet
        report_file = self.report_dir / f"ralph_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(evidence, f, indent=2, ensure_ascii=False)
        
        return evidence
    
    def run_iteration(self) -> Dict:
        """Tek Ralph iterasyonu"""
        results = {}
        
        # 1. Analyze
        results['analyze'] = self.run_flutter_analyze()
        
        # 2. Test
        results['test'] = self.run_flutter_test()
        
        # 3. Format check
        results['format'] = self.run_dart_format_check()
        
        # 4. Collect evidence
        evidence = self.collect_evidence(results)
        
        return evidence
    
    def run_ralph_mode(self, iterations: int = 3) -> List[Dict]:
        """Ralph Wiggum Mode - N iterasyon otonom QA"""
        print(f"\n🎭 RALPH WIGGUM MODE - {iterations} iterations")
        print("=" * 60)
        
        if not self.check_flutter_project():
            print("❌ Flutter projesi bulunamadı!")
            return []
        
        all_results = []
        
        for i in range(iterations):
            print(f"\n--- Iteration {i+1}/{iterations} ---")
            
            result = self.run_iteration()
            all_results.append(result)
            
            summary = result['summary']
            
            print(f"\n📊 Iteration {i+1} Summary:")
            print(f"   All Passed: {'✅' if summary['all_passed'] else '❌'}")
            print(f"   Issues: {summary['issues_found']}")
            print(f"   Tests: {summary['tests_passed']} passed, {summary['tests_failed']} failed")
            if summary['coverage']:
                print(f"   Coverage: {summary['coverage']}%")
            
            # Eğer hepsi geçtiyse erken çık
            if summary['all_passed'] and summary['tests_failed'] == 0:
                print(f"\n🎉 All checks passed at iteration {i+1}!")
                break
        
        print("\n" + "=" * 60)
        print("🎭 RALPH WIGGUM COMPLETE")
        
        return all_results
    
    def print_summary(self, results: List[Dict]):
        """Final özet yazdır"""
        if not results:
            return
        
        final = results[-1]['summary']
        
        print("\n" + "=" * 60)
        print("📋 FINAL QA REPORT")
        print("=" * 60)
        print(f"Status: {'✅ ALL PASSED' if final['all_passed'] else '❌ ISSUES FOUND'}")
        print(f"Lint Issues: {final['issues_found']}")
        print(f"Tests Passed: {final['tests_passed']}")
        print(f"Tests Failed: {final['tests_failed']}")
        if final['coverage']:
            print(f"Coverage: {final['coverage']}%")
        print("=" * 60)


def main():
    parser = argparse.ArgumentParser(
        description='Ralph Wiggum - Autonomous QA for Flutter',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('--project', default='.', help='Flutter project path')
    parser.add_argument('--iterations', type=int, default=3, help='Number of QA iterations')
    parser.add_argument('--analyze', action='store_true', help='Run flutter analyze only')
    parser.add_argument('--test', action='store_true', help='Run flutter test only')
    parser.add_argument('--lint', action='store_true', help='Run dart format check only')
    parser.add_argument('--build', action='store_true', help='Run flutter build only')
    parser.add_argument('--full', action='store_true', help='Run full Ralph mode')
    
    args = parser.parse_args()
    ralph = RalphWiggum(args.project)
    
    if args.analyze:
        result = ralph.run_flutter_analyze()
        print(json.dumps(result, indent=2))
    elif args.test:
        result = ralph.run_flutter_test()
        print(json.dumps(result, indent=2))
    elif args.lint:
        result = ralph.run_dart_format_check()
        print(json.dumps(result, indent=2))
    elif args.build:
        result = ralph.run_flutter_build()
        print(json.dumps(result, indent=2))
    elif args.full or args.iterations:
        results = ralph.run_ralph_mode(args.iterations)
        ralph.print_summary(results)
    else:
        # Default: single iteration
        results = ralph.run_ralph_mode(1)
        ralph.print_summary(results)


if __name__ == '__main__':
    main()
