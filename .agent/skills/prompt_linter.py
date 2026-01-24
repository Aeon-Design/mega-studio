#!/usr/bin/env python3
"""
Prompt Linter - PTCF Framework Compliance Checker
Ajan prompt'larını analiz eder ve eksik bileşenleri tespit eder.

Kullanım:
  python prompt_linter.py --file /path/to/agent.md
  python prompt_linter.py --all                    # Tüm ajanları kontrol et
  python prompt_linter.py --fix --file agent.md    # Otomatik düzeltme öner
"""

import argparse
import re
import json
from pathlib import Path
from typing import Dict, List, Tuple

class PTCFLinter:
    """PTCF (Persona, Task, Context, Format) compliance checker"""
    
    PERSONA_PATTERNS = [
        r'sen\s+\w+\s*(olarak|gibi)',
        r'you\s+are\s+(a|an|the)',
        r'act\s+as\s+(a|an)',
        r'role[:\s]',
        r'persona[:\s]',
        r'kimlik',
        r'identity',
        r'expertise',
        r'uzman',
        r'specialist',
        r'developer',
        r'architect',
        r'engineer',
        r'yıl\s+deneyim',
        r'years?\s+of\s+experience',
    ]
    
    TASK_PATTERNS = [
        r'görev[:\s]',
        r'task[:\s]',
        r'responsibility',
        r'sorumluluk',
        r'yapacak',
        r'will\s+do',
        r'must\s+do',
        r'should\s+do',
        r'execute',
        r'implement',
        r'create',
        r'analyze',
        r'review',
        r'oluştur',
        r'analiz\s+et',
        r'kontrol\s+et',
    ]
    
    CONTEXT_PATTERNS = [
        r'context[:\s]',
        r'bağlam[:\s]',
        r'background',
        r'constraint',
        r'kısıtlama',
        r'requirement',
        r'gereksinim',
        r'project\s+type',
        r'proje\s+tipi',
        r'tech\s+stack',
        r'dependency',
        r'when\s+to\s+use',
        r'ne\s+zaman',
    ]
    
    FORMAT_PATTERNS = [
        r'format[:\s]',
        r'output[:\s]',
        r'çıktı[:\s]',
        r'response\s+format',
        r'structure',
        r'yapı',
        r'template',
        r'şablon',
        r'bullet',
        r'table',
        r'markdown',
        r'json',
        r'code\s+block',
    ]
    
    def __init__(self, agents_dir: str = None):
        self.agents_dir = Path(agents_dir) if agents_dir else Path.home() / '.agent' / 'agents'
    
    def _check_patterns(self, content: str, patterns: List[str]) -> Tuple[bool, List[str]]:
        """Pattern'leri kontrol et ve eşleşmeleri döndür"""
        content_lower = content.lower()
        matches = []
        
        for pattern in patterns:
            if re.search(pattern, content_lower, re.IGNORECASE):
                matches.append(pattern)
        
        return len(matches) > 0, matches
    
    def _calculate_score(self, results: Dict) -> int:
        """PTCF skoru hesapla (0-100)"""
        score = 0
        weights = {'persona': 25, 'task': 30, 'context': 25, 'format': 20}
        
        for component, weight in weights.items():
            if results[component]['found']:
                # Eşleşme sayısına göre bonus
                match_count = len(results[component]['matches'])
                if match_count >= 3:
                    score += weight
                elif match_count >= 2:
                    score += weight * 0.8
                else:
                    score += weight * 0.6
        
        return int(score)
    
    def lint_file(self, file_path: Path) -> Dict:
        """Tek dosyayı lint et"""
        try:
            content = file_path.read_text(encoding='utf-8', errors='ignore')
        except Exception:
            content = ""
        
        results = {
            'file': str(file_path),
            'persona': {'found': False, 'matches': []},
            'task': {'found': False, 'matches': []},
            'context': {'found': False, 'matches': []},
            'format': {'found': False, 'matches': []},
            'score': 0,
            'issues': [],
            'suggestions': []
        }
        
        # PTCF Check
        results['persona']['found'], results['persona']['matches'] = \
            self._check_patterns(content, self.PERSONA_PATTERNS)
        
        results['task']['found'], results['task']['matches'] = \
            self._check_patterns(content, self.TASK_PATTERNS)
        
        results['context']['found'], results['context']['matches'] = \
            self._check_patterns(content, self.CONTEXT_PATTERNS)
        
        results['format']['found'], results['format']['matches'] = \
            self._check_patterns(content, self.FORMAT_PATTERNS)
        
        # Issues ve Suggestions
        if not results['persona']['found']:
            results['issues'].append('❌ Persona tanımı eksik')
            results['suggestions'].append('Ekle: "Sen [ROL] olarak davran" veya "You are a [ROLE]"')
        
        if not results['task']['found']:
            results['issues'].append('❌ Task tanımı eksik')
            results['suggestions'].append('Ekle: "Görevin: [NET EYLEM]" veya "Your task is to [ACTION]"')
        
        if not results['context']['found']:
            results['issues'].append('⚠️ Context bilgisi eksik')
            results['suggestions'].append('Ekle: Bağlam, kısıtlamalar, proje tipi bilgisi')
        
        if not results['format']['found']:
            results['issues'].append('⚠️ Format belirtilmemiş')
            results['suggestions'].append('Ekle: Çıktı formatı (bullet, table, code, etc.)')
        
        results['score'] = self._calculate_score(results)
        
        return results
    
    def lint_all(self) -> List[Dict]:
        """Tüm ajanları lint et"""
        results = []
        
        if not self.agents_dir.exists():
            print(f"⚠️ Agents directory not found: {self.agents_dir}")
            return results
        
        for agent_file in self.agents_dir.glob('*.md'):
            result = self.lint_file(agent_file)
            results.append(result)
        
        return results
    
    def generate_report(self, results: List[Dict]) -> str:
        """Lint raporu oluştur"""
        output = []
        output.append("=" * 70)
        output.append("🔍 PTCF PROMPT LINTER REPORT")
        output.append("=" * 70)
        
        # Summary
        total = len(results)
        passing = sum(1 for r in results if r['score'] >= 70)
        warning = sum(1 for r in results if 40 <= r['score'] < 70)
        failing = sum(1 for r in results if r['score'] < 40)
        
        output.append(f"\n📊 Summary: {total} agents analyzed")
        output.append(f"   ✅ Passing (≥70): {passing}")
        output.append(f"   ⚠️ Warning (40-69): {warning}")
        output.append(f"   ❌ Failing (<40): {failing}")
        
        # Score distribution
        avg_score = sum(r['score'] for r in results) / total if total > 0 else 0
        output.append(f"   📈 Average Score: {avg_score:.1f}/100")
        
        # Detailed results
        output.append("\n" + "-" * 70)
        output.append("📋 DETAILED RESULTS")
        output.append("-" * 70)
        
        # Sort by score (lowest first)
        sorted_results = sorted(results, key=lambda x: x['score'])
        
        for r in sorted_results:
            file_name = Path(r['file']).name
            score = r['score']
            
            if score >= 70:
                status = "✅"
            elif score >= 40:
                status = "⚠️"
            else:
                status = "❌"
            
            output.append(f"\n{status} {file_name}: {score}/100")
            
            # PTCF breakdown
            p = "✓" if r['persona']['found'] else "✗"
            t = "✓" if r['task']['found'] else "✗"
            c = "✓" if r['context']['found'] else "✗"
            f = "✓" if r['format']['found'] else "✗"
            output.append(f"   [P]{p} [T]{t} [C]{c} [F]{f}")
            
            # Issues
            if r['issues'] and score < 70:
                for issue in r['issues'][:2]:  # Max 2 issues
                    output.append(f"   {issue}")
        
        output.append("\n" + "=" * 70)
        
        return '\n'.join(output)
    
    def suggest_fix(self, file_path: Path) -> str:
        """Düzeltme önerisi oluştur"""
        result = self.lint_file(file_path)
        
        output = []
        output.append(f"📝 Fix Suggestions for: {file_path.name}")
        output.append("-" * 50)
        
        if not result['persona']['found']:
            output.append("""
## Persona Ekle

```markdown
## Kimlik

Sen **[AJAN_ADI]** olarak davran - [KISA_TANIM].
[ALAN] konusunda 10+ yıl deneyime sahipsin.
```
""")
        
        if not result['task']['found']:
            output.append("""
## Task Ekle

```markdown
## Görevler

### Ana Görev
[NET EYLEM] yap.

### Alt Görevler
1. [ADIM_1]
2. [ADIM_2]
3. [ADIM_3]
```
""")
        
        if not result['context']['found']:
            output.append("""
## Context Ekle

```markdown
## Bağlam

### Ne Zaman Kullanılır
- [SENARYO_1]
- [SENARYO_2]

### Kısıtlamalar
- [KISITLAMA_1]
- [KISITLAMA_2]
```
""")
        
        if not result['format']['found']:
            output.append("""
## Format Ekle

```markdown
## Çıktı Formatı

Yanıtlarını şu formatta ver:

### Analiz
| Bileşen | Durum | Öneri |
|---------|-------|-------|
| X | ✅/❌ | ... |

### Sonuç
- Bullet 1
- Bullet 2
```
""")
        
        return '\n'.join(output)


def main():
    parser = argparse.ArgumentParser(
        description='PTCF Prompt Linter for Agent Prompts'
    )
    
    parser.add_argument('--file', type=str, help='Single file to lint')
    parser.add_argument('--all', action='store_true', help='Lint all agents')
    parser.add_argument('--fix', action='store_true', help='Generate fix suggestions')
    parser.add_argument('--agents-dir', type=str, 
                        default=str(Path.home() / '.agent' / 'agents'),
                        help='Agents directory path')
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    
    args = parser.parse_args()
    linter = PTCFLinter(args.agents_dir)
    
    if args.file:
        file_path = Path(args.file)
        if not file_path.exists():
            print(f"❌ File not found: {file_path}")
            return
        
        if args.fix:
            print(linter.suggest_fix(file_path))
        else:
            result = linter.lint_file(file_path)
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                print(linter.generate_report([result]))
    
    elif args.all:
        results = linter.lint_all()
        if args.json:
            print(json.dumps(results, indent=2))
        else:
            print(linter.generate_report(results))
    
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
