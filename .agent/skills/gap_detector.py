#!/usr/bin/env python3
"""
Gap Detector - Agent Capability Gap Analysis System
Kullanıcı isteğine uygun ajan bulur, yoksa yeni ajan önerir.

Kullanım:
  python gap_detector.py --query "Bluetooth entegrasyonu"
  python gap_detector.py --query "AR deneyimi oluştur"
  python gap_detector.py --list-gaps
  python gap_detector.py --create-agent "AR Specialist"
"""

import argparse
import json
import os
import re
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from datetime import datetime

class GapDetector:
    """Agent capability gap detection system"""
    
    def __init__(self, registry_path: str = None, agents_dir: str = None):
        self.registry_path = Path(registry_path) if registry_path else Path.home() / '.agent' / 'agent_registry.json'
        self.agents_dir = Path(agents_dir) if agents_dir else Path.home() / '.agent' / 'agents'
        self.workflows_dir = Path.home() / '.gemini' / 'antigravity' / 'global_workflows'
        self.registry = self._load_registry()
    
    def _load_registry(self) -> Dict:
        """Load agent registry"""
        if self.registry_path.exists():
            with open(self.registry_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {"agents": [], "uncovered_domains": []}
    
    def _save_registry(self):
        """Save registry to file"""
        with open(self.registry_path, 'w', encoding='utf-8') as f:
            json.dump(self.registry, f, indent=2, ensure_ascii=False)
    
    def find_matching_agents(self, query: str, top_n: int = 3) -> List[Tuple[Dict, float]]:
        """Find agents matching the query based on keywords"""
        query_lower = query.lower()
        query_words = set(re.findall(r'\w+', query_lower))
        
        scores = []
        
        for agent in self.registry.get('agents', []):
            score = 0
            matched_keywords = []
            
            # Check keywords
            for keyword in agent.get('keywords', []):
                keyword_lower = keyword.lower()
                if keyword_lower in query_lower:
                    score += 3
                    matched_keywords.append(keyword)
                elif any(kw in keyword_lower for kw in query_words):
                    score += 1
                    matched_keywords.append(keyword)
            
            # Check capabilities
            for cap in agent.get('capabilities', []):
                if cap.lower() in query_lower or any(w in cap.lower() for w in query_words):
                    score += 2
            
            # Check domains
            for domain in agent.get('domains', []):
                if domain.lower() in query_lower:
                    score += 2
            
            if score > 0:
                scores.append((agent, score, matched_keywords))
        
        # Sort by score descending
        scores.sort(key=lambda x: x[1], reverse=True)
        
        return [(agent, score) for agent, score, _ in scores[:top_n]]
    
    def detect_gap(self, query: str) -> Dict:
        """Detect if there's a capability gap for the given query"""
        matches = self.find_matching_agents(query)
        
        result = {
            'query': query,
            'gap_detected': False,
            'matching_agents': [],
            'confidence': 'high',
            'recommendation': None,
            'suggested_agent': None
        }
        
        if not matches:
            # No matching agent found - definite gap
            result['gap_detected'] = True
            result['confidence'] = 'high'
            result['recommendation'] = f"'{query}' icin uygun ajan bulunamadi. Yeni ajan olusturulabilir."
            result['suggested_agent'] = self._suggest_new_agent(query)
        elif matches[0][1] < 3:
            # Low confidence match - possible gap
            result['gap_detected'] = True
            result['confidence'] = 'medium'
            result['matching_agents'] = [{'name': m[0]['name'], 'score': m[1]} for m in matches]
            result['recommendation'] = f"Dusuk eslesme skoru. Mevcut ajanlar yetersiz olabilir."
            result['suggested_agent'] = self._suggest_new_agent(query)
        else:
            # Good match found
            result['matching_agents'] = [{'name': m[0]['name'], 'score': m[1], 'file': m[0]['file']} for m in matches]
            result['recommendation'] = f"Onerilen ajan: {matches[0][0]['name']}"
        
        return result
    
    def _suggest_new_agent(self, query: str) -> Dict:
        """Suggest a new agent based on the query"""
        # Extract potential domain/capability from query
        words = re.findall(r'\w+', query.lower())
        
        # Common domain mappings
        domain_hints = {
            'ar': 'AR/VR Specialist',
            'vr': 'AR/VR Specialist',
            'augmented': 'AR/VR Specialist',
            'virtual': 'AR/VR Specialist',
            'watch': 'Wearables Specialist',
            'wearable': 'Wearables Specialist',
            'payment': 'Payment Integration Specialist',
            'stripe': 'Payment Integration Specialist',
            'social': 'Social Features Specialist',
            'chat': 'Chat/Messaging Specialist',
            'notification': 'Push Notification Specialist',
            'deep': 'Deep Linking Specialist',
            'link': 'Deep Linking Specialist',
            'tv': 'TV App Specialist',
            'automotive': 'Automotive Integration Specialist',
            'car': 'Automotive Integration Specialist',
            'nfc': 'NFC Specialist',
            'biometric': 'Biometric Auth Specialist',
            'face': 'Biometric Auth Specialist',
            'fingerprint': 'Biometric Auth Specialist',
            '3d': '3D Graphics Specialist',
            'shader': 'Shader Specialist',
            'map': 'Maps Integration Specialist',
            'location': 'Location Services Specialist',
            'gps': 'Location Services Specialist',
            'camera': 'Camera/Media Specialist',
            'video': 'Video Processing Specialist',
            'audio': 'Audio Processing Specialist',
            'voice': 'Voice/Speech Specialist',
            'speech': 'Voice/Speech Specialist',
        }
        
        suggested_name = None
        for word in words:
            if word in domain_hints:
                suggested_name = domain_hints[word]
                break
        
        if not suggested_name:
            # Generic suggestion based on query
            main_word = max(words, key=len) if words else 'Unknown'
            suggested_name = f"{main_word.capitalize()} Specialist"
        
        return {
            'name': suggested_name,
            'suggested_capabilities': words[:5],
            'suggested_domains': words[:3]
        }
    
    def list_uncovered_domains(self) -> List[str]:
        """List domains that have no agent coverage"""
        return self.registry.get('uncovered_domains', [])
    
    def create_agent(self, name: str, capabilities: List[str] = None, domains: List[str] = None) -> str:
        """Create a new agent with PTCF format"""
        # Generate file name
        file_name = name.lower().replace(' ', '-').replace('/', '-') + '.md'
        file_path = self.agents_dir / file_name
        
        # Generate agent ID
        agent_id = name.lower().replace(' ', '-').replace('/', '-')
        
        # Default values
        caps = capabilities or ['specialized-analysis', 'implementation', 'optimization']
        doms = domains or ['specialized']
        
        # PTCF Template
        content = f'''---
name: "{name}"
title: "The Specialist"
department: "Specialized"
reports_to: "CTO"
version: "2.0.0"
skills: []
---

# 🎯 {name}

## [P] Persona

Sen **{name}**sin - {', '.join(doms)} alaninda uzman.

**Deneyim:** 8+ yil uzmanlik alani
**Uzmanlık:** {', '.join(caps)}
**Felsefe:** "Excellence in specialized domain."

---

## [T] Task - Gorevler

### Ana Gorev
Uzmanlik alaninda analiz yap, implement et ve optimize et.

### Alt Gorevler
1. **Analiz** - Domain-specific analiz
2. **Implementation** - Ozellik gelistirme
3. **Optimization** - Performans iyilestirme
4. **Documentation** - Best practices dokumantasyonu

---

## [C] Context - Baglam

### Ne Zaman Kullanilir
- {doms[0] if doms else 'Specialized'} konusunda is yapilacaksa
- Domain-specific expertise gerektiginde

### Onemli Bilgiler
- Bu ajan Gap Detector tarafindan olusturuldu
- Olusturulma: {datetime.now().strftime('%Y-%m-%d')}

---

## [F] Format - Cikti Yapisi

### Standard Report
```markdown
## [{doms[0].capitalize() if doms else 'Topic'}] Analysis

### Findings
- [Finding 1]
- [Finding 2]

### Implementation
```dart
// Code implementation
```

### Recommendations
- [Rec 1]
- [Rec 2]
```

---

## 🔬 Self-Audit

- [ ] Domain expertise uygulandı mı?
- [ ] Best practices takip edildi mi?
- [ ] Documentation guncellendi mi?
'''
        
        # Write agent file
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        # Create workflow
        workflow_content = f'''---
description: {name} - Specialized expertise
---

1. Bu workflow {name} ajanini aktive eder.
2. Ilgili ajan dosyasini oku ve persona'yi benimse.
3. Uzmanlik alaninda analiz ve implementation yap.
'''
        workflow_path = self.workflows_dir / f"{agent_id}.md"
        with open(workflow_path, 'w', encoding='utf-8') as f:
            f.write(workflow_content)
        
        # Add to registry
        new_agent = {
            'id': agent_id,
            'name': name,
            'file': file_name,
            'capabilities': caps,
            'domains': doms,
            'keywords': caps + doms,
            'auto_created': True,
            'created_date': datetime.now().strftime('%Y-%m-%d')
        }
        self.registry['agents'].append(new_agent)
        self._save_registry()
        
        return f"Ajan olusturuldu: {file_path}\nWorkflow: {workflow_path}"
    
    def analyze_request(self, query: str) -> str:
        """Main entry point - analyze request and provide recommendation"""
        result = self.detect_gap(query)
        
        output = []
        output.append("=" * 60)
        output.append("🔍 AGENT GAP ANALYSIS")
        output.append("=" * 60)
        output.append(f"\nQuery: {query}")
        output.append("-" * 60)
        
        if result['gap_detected']:
            output.append(f"\n⚠️ GAP DETECTED (Confidence: {result['confidence']})")
            output.append(f"\n{result['recommendation']}")
            
            if result['matching_agents']:
                output.append("\nPartial matches (low confidence):")
                for agent in result['matching_agents']:
                    output.append(f"  - {agent['name']} (score: {agent['score']})")
            
            if result['suggested_agent']:
                output.append(f"\n💡 Suggested New Agent: {result['suggested_agent']['name']}")
                output.append(f"   Capabilities: {', '.join(result['suggested_agent']['suggested_capabilities'])}")
                output.append("\n   To create: python gap_detector.py --create-agent \"" + result['suggested_agent']['name'] + "\"")
        else:
            output.append("\n✅ MATCHING AGENTS FOUND")
            for agent in result['matching_agents']:
                output.append(f"\n  📌 {agent['name']} (score: {agent['score']})")
                output.append(f"     File: {agent['file']}")
                output.append(f"     Command: /{agent['file'].replace('.md', '')}")
        
        output.append("\n" + "=" * 60)
        
        return '\n'.join(output)


def main():
    parser = argparse.ArgumentParser(description='Agent Gap Detector')
    parser.add_argument('--query', '-q', type=str, help='Query to find matching agents')
    parser.add_argument('--list-gaps', action='store_true', help='List uncovered domains')
    parser.add_argument('--create-agent', type=str, help='Create new agent with given name')
    parser.add_argument('--capabilities', type=str, help='Comma-separated capabilities for new agent')
    parser.add_argument('--domains', type=str, help='Comma-separated domains for new agent')
    
    args = parser.parse_args()
    detector = GapDetector()
    
    if args.query:
        print(detector.analyze_request(args.query))
    
    elif args.list_gaps:
        gaps = detector.list_uncovered_domains()
        print("Uncovered Domains:")
        for gap in gaps:
            print(f"  - {gap}")
    
    elif args.create_agent:
        caps = args.capabilities.split(',') if args.capabilities else None
        doms = args.domains.split(',') if args.domains else None
        result = detector.create_agent(args.create_agent, caps, doms)
        print(result)
    
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
