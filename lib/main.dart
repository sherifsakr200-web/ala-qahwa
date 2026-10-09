import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const DominoCounterApp());
}

class DominoCounterApp extends StatelessWidget {
  const DominoCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'عداد الدومينو',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4D3E),
          brightness: Brightness.dark,
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SetupScreen(),
    );
  }
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _team1Controller = TextEditingController(text: 'الفريق الأول');
  final TextEditingController _team2Controller = TextEditingController(text: 'الفريق الثاني');
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عداد الدومينو - إعداد الجيم'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.casino, size: 80, color: Color(0xFF4CAF50)),
              const SizedBox(height: 20),
              const Text(
                'سجل أسماء الفرق وابدأ التحدي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _team1Controller,
                decoration: InputDecoration(
                  labelText: 'اسم الفريق الأول',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.group),
                ),
                validator: (value) => value!.isEmpty ? 'أدخل اسم الفريق' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _team2Controller,
                decoration: InputDecoration(
                  labelText: 'اسم الفريق الثاني',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.group),
                ),
                validator: (value) => value!.isEmpty ? 'أدخل اسم الفريق' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                            team1Name: _team1Controller.text,
                            team2Name: _team2Controller.text,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('ابدأ اللعب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String team1Name;
  final String team2Name;

  const GameScreen({super.key, required this.team1Name, required this.team2Name});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int score1 = 0;
  int score2 = 0;
  final List<Map<String, int>> history = [];
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isAdLoaded = true),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _addPointsDialog(String teamName, Function(int) onPointsAdded) {
    final TextEditingController pointsController = TextEditingController();
    showDialog(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: Text('إضافة نقط لـ $teamName'),
        content: TextField(
          controller: pointsController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'أدخل عدد النقط',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              int? points = int.tryParse(pointsController.text);
              if (points != null && points > 0) {
                onPointsAdded(points);
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  BuildContext get dialogContext => context;

  void _recordRound(int p1, int p2) {
    setState(() {
      score1 += p1;
      score2 += p2;
      history.insert(0, {'t1': p1, 't2': p2});
    });
  }

  void _resetGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفير العداد'),
        content: const Text('هل أنت متأكد من تصفير النقط وبدء جيم جديد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                score1 = 0;
                score2 = 0;
                history.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('تصفير'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عداد الدومينو المفتوح'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تصفير الجيم',
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 4,
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        onTap: () => _addPointsDialog(widget.team1Name, (p) => _recordRound(p, 0)),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.team1Name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '$score1',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              const Text('اضغط للإضافة', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      elevation: 4,
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        onTap: () => _addPointsDialog(widget.team2Name, (p) => _recordRound(0, p)),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.team2Name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '$score2',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              const Text('اضغط للإضافة', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('سجل الأدوار السابقة:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            flex: 2,
            child: history.isEmpty
                ? const Center(child: Text('لا توجد أدوار مسجلة حتى الآن', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final round = history[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Text('${history.length - index}'),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${widget.team1Name}: +${round['t1']}'),
                              Text('${widget.team2Name}: +${round['t2']}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_isAdLoaded)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
