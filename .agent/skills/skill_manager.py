#!/usr/bin/env python3
"""
Skill Manager - Orchestrator için Skill Yönetim Sistemi
Kullanım: python skill_manager.py --list
         python skill_manager.py --search "bloc"
         python skill_manager.py --load clean-architecture

Bu script skill'leri keşfeder, yükler ve yönetir.
"""

import argparse
import os
import re
import yaml
from pathlib import Path
from typing import Dict, List, Optional

class SkillManager:
    """Skill yönetim sınıfı"""
    
    def __init__(self, skills_directory: str):
        self.skills_dir = Path(skills_directory)
        self.skills: Dict[str, dict] = {}
        self._load_all_skills()
    
    def _parse_frontmatter(self, content: str) -> dict:
        """YAML frontmatter'ı parse et"""
        if not content.startswith('---'):
            return {}
        
        try:
            end = content.find('---', 3)
            if end == -1:
                return {}
            yaml_content = content[3:end].strip()
            return yaml.safe_load(yaml_content) or {}
        except yaml.YAMLError:
            return {}
    
    def _load_all_skills(self):
        """Tüm skill'leri yükle"""
        if not self.skills_dir.exists():
            print(f"⚠️  Skills directory not found: {self.skills_dir}")
            return
        
        for skill_dir in self.skills_dir.iterdir():
            if not skill_dir.is_dir():
                continue
            
            skill_md = skill_dir / 'SKILL.md'
            if not skill_md.exists():
                continue
            
            content = skill_md.read_text(encoding='utf-8')
            metadata = self._parse_frontmatter(content)
            
            # Body'yi al (frontmatter sonrası)
            body_start = content.find('---', 3)
            body = content[body_start + 3:].strip() if body_start != -1 else content
            
            skill_name = metadata.get('name', skill_dir.name)
            
            self.skills[skill_name] = {
                'name': skill_name,
                'path': str(skill_dir),
                'description': metadata.get('description', ''),
                'version': metadata.get('version', '1.0.0'),
                'primary_users': metadata.get('primary_users', []),
                'dependencies': metadata.get('dependencies', []),
                'tags': metadata.get('tags', []),
                'has_scripts': (skill_dir / 'scripts').exists(),
                'has_references': (skill_dir / 'references').exists(),
                'has_assets': (skill_dir / 'assets').exists(),
                'content_preview': body[:500] + '...' if len(body) > 500 else body,
                'loaded': False,
            }
    
    def list_skills(self) -> List[dict]:
        """Tüm skill'leri listele"""
        return list(self.skills.values())
    
    def get_skill(self, name: str) -> Optional[dict]:
        """Skill bilgisini getir"""
        return self.skills.get(name)
    
    def search_skills(self, query: str) -> List[dict]:
        """Skill'lerde arama yap"""
        query_lower = query.lower()
        results = []
        
        for skill in self.skills.values():
            # Name, description ve tags'de ara
            if query_lower in skill['name'].lower():
                results.append(skill)
            elif query_lower in skill['description'].lower():
                results.append(skill)
            elif any(query_lower in tag.lower() for tag in skill['tags']):
                results.append(skill)
        
        return results
    
    def get_skills_for_agent(self, agent_name: str) -> List[dict]:
        """Bir ajan için uygun skill'leri getir"""
        agent_lower = agent_name.lower().replace('-', ' ').replace('_', ' ')
        results = []
        
        for skill in self.skills.values():
            for user in skill['primary_users']:
                user_lower = user.lower().replace('-', ' ').replace('_', ' ')
                if agent_lower in user_lower or user_lower in agent_lower:
                    results.append(skill)
                    break
        
        return results
    
    def load_skill_content(self, name: str) -> Optional[str]:
        """Skill içeriğini tam olarak yükle"""
        skill = self.skills.get(name)
        if not skill:
            return None
        
        skill_md = Path(skill['path']) / 'SKILL.md'
        content = skill_md.read_text(encoding='utf-8')
        
        skill['loaded'] = True
        return content
    
    def get_skill_scripts(self, name: str) -> List[str]:
        """Skill'in script'lerini listele"""
        skill = self.skills.get(name)
        if not skill:
            return []
        
        scripts_dir = Path(skill['path']) / 'scripts'
        if not scripts_dir.exists():
            return []
        
        return [str(f) for f in scripts_dir.glob('*.py')]
    
    def get_skill_structure(self, name: str) -> dict:
        """Skill klasör yapısını getir"""
        skill = self.skills.get(name)
        if not skill:
            return {}
        
        skill_path = Path(skill['path'])
        
        def get_tree(path: Path, depth: int = 0) -> dict:
            if depth > 3:
                return {}
            
            result = {}
            for item in sorted(path.iterdir()):
                if item.name.startswith('.'):
                    continue
                if item.is_dir():
                    result[item.name + '/'] = get_tree(item, depth + 1)
                else:
                    result[item.name] = item.stat().st_size
            return result
        
        return get_tree(skill_path)
    
    def print_skill_summary(self):
        """Skill özeti yazdır"""
        print('\n📚 MEGA STUDIO SKILLS')
        print('=' * 60)
        
        for skill in sorted(self.skills.values(), key=lambda x: x['name']):
            status = '✅' if skill['loaded'] else '⬜'
            scripts = '📜' if skill['has_scripts'] else '  '
            refs = '📖' if skill['has_references'] else '  '
            assets = '📦' if skill['has_assets'] else '  '
            
            print(f"{status} {skill['name']:<30} {scripts}{refs}{assets}")
            if skill['description']:
                desc = skill['description'][:50]
                print(f"   └─ {desc}...")
        
        print('=' * 60)
        print(f"Total: {len(self.skills)} skills")
        print('\nLegend: 📜 Scripts | 📖 References | 📦 Assets')

def main():
    parser = argparse.ArgumentParser(
        description='Mega Studio Skill Manager',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  python skill_manager.py --list
  python skill_manager.py --search "bloc"
  python skill_manager.py --load clean-architecture
  python skill_manager.py --agent mobile-developer
        '''
    )
    
    parser.add_argument('--skills-dir', 
                        default=str(Path.home() / '.agent' / 'skills'),
                        help='Skills directory path')
    parser.add_argument('--list', action='store_true',
                        help='List all skills')
    parser.add_argument('--search', type=str,
                        help='Search skills by keyword')
    parser.add_argument('--load', type=str,
                        help='Load and display skill content')
    parser.add_argument('--agent', type=str,
                        help='Get skills for a specific agent')
    parser.add_argument('--scripts', type=str,
                        help='List scripts for a skill')
    parser.add_argument('--structure', type=str,
                        help='Show skill folder structure')
    
    args = parser.parse_args()
    
    manager = SkillManager(args.skills_dir)
    
    if args.list:
        manager.print_skill_summary()
    
    elif args.search:
        results = manager.search_skills(args.search)
        print(f'\n🔍 Search results for "{args.search}":')
        for skill in results:
            print(f"  • {skill['name']}: {skill['description'][:60]}...")
    
    elif args.load:
        content = manager.load_skill_content(args.load)
        if content:
            print(content)
        else:
            print(f'❌ Skill not found: {args.load}')
    
    elif args.agent:
        skills = manager.get_skills_for_agent(args.agent)
        print(f'\n🤖 Skills for {args.agent}:')
        for skill in skills:
            print(f"  • {skill['name']}")
    
    elif args.scripts:
        scripts = manager.get_skill_scripts(args.scripts)
        print(f'\n📜 Scripts in {args.scripts}:')
        for script in scripts:
            print(f"  • {script}")
    
    elif args.structure:
        structure = manager.get_skill_structure(args.structure)
        print(f'\n📁 Structure of {args.structure}:')
        import json
        print(json.dumps(structure, indent=2))
    
    else:
        parser.print_help()

if __name__ == '__main__':
    main()
