import 'package:flutter/material.dart';
import '../models/customization.dart';
import '../services/storage_service.dart';

class CustomizationSheet extends StatefulWidget {
  final VoidCallback onChanged;
  final ValueChanged<int> onGridSizeChanged;
  const CustomizationSheet({
    super.key,
    required this.onChanged,
    required this.onGridSizeChanged,
  });

  @override
  State<CustomizationSheet> createState() => _CustomizationSheetState();
}

class _CustomizationSheetState extends State<CustomizationSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1120),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF334155), width: 1.5)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(width: 44, height: 4, decoration: BoxDecoration(color: const Color(0xFF475569), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.grid_view_rounded, color: Color(0xFFF59E0B)),
                const SizedBox(width: 10),
                const Expanded(child: Text('Customize Profile, Tray & Board', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white))),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded, color: Colors.white70)),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1E293B), height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              children: [
                _sectionTitle('Player Profile (4 Options)'),
                const SizedBox(height: 8),
                _buildProfiles(),
                const SizedBox(height: 18),
                _sectionTitle('Tray & Tile Material (4 Options)'),
                const SizedBox(height: 8),
                _buildTrayThemes(),
                const SizedBox(height: 18),
                _sectionTitle('Tabletop Background (4 Options)'),
                const SizedBox(height: 8),
                _buildBackgrounds(),
                const SizedBox(height: 18),
                _sectionTitle('Puzzle Grid Size (4 Options)'),
                const SizedBox(height: 8),
                _buildBoardModes(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
      );

  Widget _buildProfiles() {
    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: SlideCustomization.profiles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, idx) {
          final p = SlideCustomization.profiles[idx];
          final selected = StorageService.profileIndex == idx;
          return GestureDetector(
            onTap: () {
              setState(() => StorageService.profileIndex = idx);
              StorageService.save();
              widget.onChanged();
            },
            child: Container(
              width: 112,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? p.accentColor.withValues(alpha: 0.16) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: selected ? p.accentColor : const Color(0xFF334155), width: selected ? 2.2 : 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(child: Image.asset(p.assetPath, width: 56, height: 56, fit: BoxFit.cover)),
                  const SizedBox(height: 6),
                  Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: p.accentColor)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrayThemes() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(SlideCustomization.trayThemes.length, (idx) {
        final t = SlideCustomization.trayThemes[idx];
        final selected = StorageService.trayThemeIndex == idx;
        return GestureDetector(
          onTap: () {
            setState(() => StorageService.trayThemeIndex = idx);
            StorageService.save();
            widget.onChanged();
          },
          child: Container(
            width: 158,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selected ? t.tileBorder.withValues(alpha: 0.18) : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? t.tileBorder : const Color(0xFF334155), width: selected ? 2.2 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [t.tileTop, t.tileBottom]),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: t.tileBorder, width: 1.5),
                  ),
                  child: Text('24', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: t.textColor)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text(t.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBackgrounds() {
    return SizedBox(
      height: 122,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: SlideCustomization.backgrounds.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, idx) {
          final bg = SlideCustomization.backgrounds[idx];
          final selected = StorageService.backgroundIndex == idx;
          return GestureDetector(
            onTap: () {
              setState(() => StorageService.backgroundIndex = idx);
              StorageService.save();
              widget.onChanged();
            },
            child: Container(
              width: 116,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: selected ? bg.accentColor : const Color(0xFF334155), width: selected ? 2.4 : 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(bg.assetPath, fit: BoxFit.cover),
                    Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xDD020617)]))),
                    Positioned(
                      left: 8, right: 8, bottom: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bg.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                          Text(bg.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: bg.accentColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBoardModes() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(SlideCustomization.boardModes.length, (idx) {
        final mode = SlideCustomization.boardModes[idx];
        final selected = StorageService.gridSizeIndex == idx;
        return GestureDetector(
          onTap: () {
            setState(() => StorageService.gridSizeIndex = idx);
            StorageService.save();
            widget.onGridSizeChanged(mode.gridSize);
            widget.onChanged();
          },
          child: Container(
            width: 155,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF59E0B).withValues(alpha: 0.18) : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? const Color(0xFFF59E0B) : const Color(0xFF334155), width: selected ? 2 : 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mode.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                Text(mode.subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
        );
      }),
    );
  }
}

