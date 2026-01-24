#!/usr/bin/env python3
"""
Brain.py - Long-Term Memory (LTM) for Flutter Projects
Maestro-inspired proje hafıza sistemi.

Kullanım:
  python brain.py --init                    # Yeni brain oluştur
  python brain.py --add-decision "..."      # Karar ekle
  python brain.py --add-error "..."         # Hata ekle
  python brain.py --add-completed "..."     # Tamamlanan iş ekle
  python brain.py --show                    # Brain özeti göster
  python brain.py --detect-stack            # Tech stack algıla
"""

import argparse
import json
import os
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Any

class FlutterBrain:
    """Flutter projesi için kalıcı hafıza yönetimi"""
    
    def __init__(self, project_root: str = '.'):
        self.project_root = Path(project_root).resolve()
        self.maestro_dir = self.project_root / '.maestro'
        self.brain_path = self.maestro_dir / 'brain.jsonl'
    
    def _ensure_dir(self):
        """Maestro klasörünü oluştur"""
        self.maestro_dir.mkdir(parents=True, exist_ok=True)
    
    def _get_timestamp(self) -> str:
        """ISO timestamp"""
        return datetime.now().strftime('%Y-%m-%d %H:%M')
    
    def _read_entries(self) -> List[Dict]:
        """Tüm brain kayıtlarını oku"""
        if not self.brain_path.exists():
            return []
        
        entries = []
        with open(self.brain_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        entries.append(json.loads(line))
                    except json.JSONDecodeError:
                        pass
        return entries
    
    def _write_entries(self, entries: List[Dict]):
        """Tüm kayıtları yaz"""
        self._ensure_dir()
        with open(self.brain_path, 'w', encoding='utf-8') as f:
            for entry in entries:
                f.write(json.dumps(entry, ensure_ascii=False) + '\n')
    
    def _append_entry(self, entry: Dict):
        """Tek kayıt ekle"""
        self._ensure_dir()
        with open(self.brain_path, 'a', encoding='utf-8') as f:
            f.write(json.dumps(entry, ensure_ascii=False) + '\n')
    
    def detect_flutter_stack(self) -> Dict[str, Any]:
        """Flutter projesinin tech stack'ini algıla"""
        pubspec_path = self.project_root / 'pubspec.yaml'
        
        if not pubspec_path.exists():
            return {'error': 'pubspec.yaml bulunamadı'}
        
        content = pubspec_path.read_text(encoding='utf-8')
        
        # Proje adı
        name_match = re.search(r'^name:\s*(\S+)', content, re.MULTILINE)
        project_name = name_match.group(1) if name_match else 'unknown'
        
        # Flutter version
        flutter_match = re.search(r'flutter:\s*["\']?>=?(\d+\.\d+\.\d+)', content)
        flutter_version = flutter_match.group(1) if flutter_match else 'unknown'
        
        # Dependencies analizi
        deps = []
        key_deps = []
        
        # State management
        if 'flutter_bloc:' in content or 'bloc:' in content:
            key_deps.append('Bloc')
        if 'flutter_riverpod:' in content or 'riverpod:' in content:
            key_deps.append('Riverpod')
        if 'provider:' in content:
            key_deps.append('Provider')
        
        # DI
        if 'get_it:' in content:
            key_deps.append('GetIt')
        if 'injectable:' in content:
            key_deps.append('Injectable')
        
        # Network
        if 'dio:' in content:
            key_deps.append('Dio')
        if 'retrofit:' in content:
            key_deps.append('Retrofit')
        if 'http:' in content:
            key_deps.append('HTTP')
        
        # Storage
        if 'hive:' in content:
            key_deps.append('Hive')
        if 'drift:' in content or 'moor:' in content:
            key_deps.append('Drift')
        if 'shared_preferences:' in content:
            key_deps.append('SharedPreferences')
        if 'flutter_secure_storage:' in content:
            key_deps.append('SecureStorage')
        
        # Code gen
        if 'freezed:' in content:
            key_deps.append('Freezed')
        if 'json_serializable:' in content:
            key_deps.append('JsonSerializable')
        
        # Routing
        if 'go_router:' in content:
            key_deps.append('GoRouter')
        if 'auto_route:' in content:
            key_deps.append('AutoRoute')
        
        # Firebase
        if 'firebase_core:' in content:
            key_deps.append('Firebase')
        
        # Architecture detection
        patterns = []
        lib_path = self.project_root / 'lib'
        
        if lib_path.exists():
            subdirs = [d.name for d in lib_path.iterdir() if d.is_dir()]
            
            if 'features' in subdirs and any(
                (lib_path / 'features').iterdir()
            ):
                patterns.append('Feature-First')
            
            if any(d in subdirs for d in ['domain', 'data', 'presentation']):
                patterns.append('Clean Architecture')
            
            if 'core' in subdirs:
                patterns.append('Core Module')
            
            if 'shared' in subdirs or 'common' in subdirs:
                patterns.append('Shared Module')
        
        return {
            'project_name': project_name,
            'flutter_version': flutter_version,
            'state_management': [d for d in key_deps if d in ['Bloc', 'Riverpod', 'Provider']],
            'key_deps': key_deps,
            'patterns': patterns,
            'detected_at': self._get_timestamp()
        }
    
    def init_brain(self):
        """Brain'i başlat ve tech stack algıla"""
        tech_info = self.detect_flutter_stack()
        
        if 'error' in tech_info:
            print(f"⚠️  {tech_info['error']}")
            return
        
        # Mevcut brain'i temizle ve yeniden oluştur
        entries = []
        
        # Tech stack entry
        entries.append({
            'type': 'tech_stack',
            'ts': self._get_timestamp(),
            'project_name': tech_info['project_name'],
            'flutter_version': tech_info['flutter_version'],
            'state_management': tech_info['state_management'],
            'key_deps': tech_info['key_deps'],
            'patterns': tech_info['patterns']
        })
        
        self._write_entries(entries)
        
        print(f"🧠 Brain initialized for: {tech_info['project_name']}")
        print(f"   Flutter: {tech_info['flutter_version']}")
        print(f"   State: {', '.join(tech_info['state_management']) or 'None'}")
        print(f"   Deps: {', '.join(tech_info['key_deps'][:5])}...")
        print(f"   Patterns: {', '.join(tech_info['patterns']) or 'None'}")
        print(f"\n📁 Created: {self.brain_path}")
    
    def add_entry(self, entry_type: str, content: str):
        """Yeni kayıt ekle"""
        entry = {
            'type': entry_type,
            'ts': self._get_timestamp(),
            'content': content
        }
        self._append_entry(entry)
        print(f"✓ Added {entry_type}: {content[:50]}...")
    
    def add_decision(self, decision: str):
        """Mimari karar ekle"""
        self.add_entry('decision', decision)
    
    def add_error(self, error: str):
        """Bilinen hata ekle"""
        self.add_entry('error', error)
    
    def add_completed(self, task: str):
        """Tamamlanan iş ekle"""
        self.add_entry('completed', task)
    
    def add_goal(self, goal: str):
        """Proje hedefi ekle"""
        self.add_entry('goal', goal)
    
    def add_compact(self, summary: str):
        """Session özeti ekle"""
        entry = {
            'type': 'compact',
            'ts': self._get_timestamp(),
            'summary': summary
        }
        self._append_entry(entry)
        print(f"✓ Session compacted")
    
    def show_brain(self) -> str:
        """Brain özetini göster"""
        entries = self._read_entries()
        
        if not entries:
            return "🧠 Brain boş. --init ile başlat."
        
        output = []
        output.append("=" * 60)
        output.append("🧠 PROJECT BRAIN (Long-Term Memory)")
        output.append("=" * 60)
        
        # Kategorize
        tech_stack = None
        goals = []
        decisions = []
        completed = []
        errors = []
        compacts = []
        
        for e in entries:
            t = e.get('type', '')
            if t == 'tech_stack':
                tech_stack = e
            elif t == 'goal':
                goals.append(e.get('content', ''))
            elif t == 'decision':
                decisions.append(e.get('content', ''))
            elif t == 'completed':
                completed.append(e.get('content', ''))
            elif t == 'error':
                errors.append(e.get('content', ''))
            elif t == 'compact':
                compacts.append(f"[{e.get('ts', '')}] {e.get('summary', '')}")
        
        # Tech Stack
        if tech_stack:
            output.append("\n### 🔧 Tech Stack")
            output.append(f"**Project:** {tech_stack.get('project_name', 'Unknown')}")
            output.append(f"**Flutter:** {tech_stack.get('flutter_version', 'Unknown')}")
            if tech_stack.get('state_management'):
                output.append(f"**State:** {', '.join(tech_stack['state_management'])}")
            if tech_stack.get('key_deps'):
                output.append(f"**Deps:** {', '.join(tech_stack['key_deps'][:8])}")
            if tech_stack.get('patterns'):
                output.append(f"**Patterns:** {', '.join(tech_stack['patterns'])}")
        
        # Recent compact
        if compacts:
            output.append("\n### 📦 Recent Session")
            output.append(compacts[-1])
        
        # Goals
        if goals:
            output.append("\n### 🎯 Goals")
            for g in goals[-3:]:
                output.append(f"- {g}")
        
        # Decisions
        if decisions:
            output.append("\n### 🧠 Key Decisions")
            for d in decisions[-3:]:
                output.append(f"- {d[:100]}...")
        
        # Completed
        if completed:
            output.append("\n### ✅ Completed")
            for c in completed[-5:]:
                output.append(f"- {c[:80]}...")
        
        # Errors
        if errors:
            output.append("\n### 🚨 Known Issues")
            for e in errors[-3:]:
                output.append(f"- {e[:100]}...")
        
        output.append("\n" + "=" * 60)
        
        return '\n'.join(output)
    
    def get_context_for_ai(self) -> str:
        """AI için brain context'i oluştur"""
        return self.show_brain()


def main():
    parser = argparse.ArgumentParser(
        description='Flutter Project Brain (Long-Term Memory)',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('--project', default='.', help='Project root path')
    parser.add_argument('--init', action='store_true', help='Initialize brain')
    parser.add_argument('--show', action='store_true', help='Show brain summary')
    parser.add_argument('--detect-stack', action='store_true', help='Detect tech stack')
    parser.add_argument('--add-decision', type=str, help='Add architectural decision')
    parser.add_argument('--add-error', type=str, help='Add known error')
    parser.add_argument('--add-completed', type=str, help='Add completed task')
    parser.add_argument('--add-goal', type=str, help='Add project goal')
    parser.add_argument('--compact', type=str, help='Add session summary')
    
    args = parser.parse_args()
    brain = FlutterBrain(args.project)
    
    if args.init:
        brain.init_brain()
    elif args.show:
        print(brain.show_brain())
    elif args.detect_stack:
        info = brain.detect_flutter_stack()
        print(json.dumps(info, indent=2, ensure_ascii=False))
    elif args.add_decision:
        brain.add_decision(args.add_decision)
    elif args.add_error:
        brain.add_error(args.add_error)
    elif args.add_completed:
        brain.add_completed(args.add_completed)
    elif args.add_goal:
        brain.add_goal(args.add_goal)
    elif args.compact:
        brain.add_compact(args.compact)
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
