// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<String> tips = [
    "🩺 Get screened every 3 years from age 25.",
    "💉 HPV vaccine is most effective before sexual activity.",
    "🥗 Healthy lifestyle lowers cancer risk.",
    "🫂 Early detection saves lives. Don’t delay.",
    "📍 Visit clinics with certified gynecologists.",
  ];

  String? userId;
  String? therapistId;
  int _currentTip = 0;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userId = user?.uid;
    therapistId = user?.uid;
    Future.delayed(const Duration(seconds: 4), rotateTip);
  }

  void rotateTip() {
    if (!mounted) return;
    setState(() {
      _currentTip = (_currentTip + 1) % tips.length;
    });
    Future.delayed(const Duration(seconds: 4), rotateTip);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 172, 207, 235),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                actions: [Image.asset('assets/Doctor-pana.png')],
                backgroundColor: const Color.fromARGB(255, 151, 197, 240),
                expandedHeight: 80,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'DadaCare',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 63, 116, 231),
                          Color.fromARGB(255, 57, 145, 226),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Karibu, Dada 💕",
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 14, 93, 211),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tuzuie saratani ya mlango wa kizazi kwa pamoja.",
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 41, 12, 21),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        transitionBuilder:
                            (child, animation) => FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                        child: Text(
                          tips[_currentTip],
                          key: ValueKey<int>(_currentTip),
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: const Color.fromARGB(255, 27, 93, 154),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 12),
                    child: _ScrollDownHint(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                    children: [
                      _AnimatedCard(
                        icon: Icons.health_and_safety,
                        label: "AI Reccomendations",
                        color: const Color.fromARGB(255, 105, 6, 129),
                        onTap: () {
                          Navigator.of(context).pushNamed('/risk');
                        },
                      ),
                      _AnimatedCard(
                        icon: Icons.local_hospital,
                        label: "Clinics",
                        color: const Color(0xff80cbc4),
                        onTap: () {
                          Navigator.of(context).pushNamed('/hospitals');
                        },
                      ),
                      _AnimatedCard(
                        icon: Icons.monetization_on_outlined,
                        label: "Pricing",
                        color: const Color.fromARGB(255, 37, 192, 17),
                        onTap: () {
                          Navigator.of(context).pushNamed('/price');
                        },
                      ),
                      _AnimatedCard(
                        icon: Icons.text_format,
                        label: "Book Appointment",
                        color: const Color(0xff616161),
                        onTap: () {
                          Navigator.of(context).pushNamed('/book');
                        },
                      ),
                      _AnimatedCard(
                        icon: Icons.psychology_outlined,
                        label: "Consult A Doctor",
                        color: const Color.fromRGBO(171, 71, 188, 1),
                        onTap: () async {
                          if (therapistId == null) return;

                          final snapshot =
                              await FirebaseDatabase.instance
                                  .ref()
                                  .child('therapists/$therapistId')
                                  .get();

                          if (snapshot.exists) {
                            Navigator.pushNamed(
                              context,
                              '/therapist',
                              arguments: {
                                'userId': userId,
                                'therapistId': therapistId,
                              },
                            );
                          } else {
                            Navigator.pushNamed(context, '/therapist');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 150)),
            ],
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Talk to DadaCare Assistant",
                    style: TextStyle(
                      color: Color.fromARGB(255, 102, 75, 155),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/chat');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xffd1c4e9),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff9575cd).withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: Color(0xff512da8),
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AnimatedCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: widget.color.withOpacity(0.2),
                  child: Icon(widget.icon, color: widget.color, size: 26),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.label,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScrollDownHint extends StatefulWidget {
  @override
  State<_ScrollDownHint> createState() => _ScrollDownHintState();
}

class _ScrollDownHintState extends State<_ScrollDownHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder:
          (_, __) => Transform.translate(
            offset: Offset(0, _animation.value),
            child: const Icon(
              Icons.keyboard_arrow_down,
              size: 32,
              color: Color(0xff616161),
            ),
          ),
    );
  }
}
