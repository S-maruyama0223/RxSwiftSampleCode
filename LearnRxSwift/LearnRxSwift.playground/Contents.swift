import RxSwift
import Foundation

let prices = [100, 250, 560, 980]
let taxRate = 1.08

// オブザーバブルサンプル
Observable
    // from: Observableのインスタンスを生成するメソッド
    .from(prices)
    .map({ price in
        Int(Double(price) * taxRate)
    })
    .subscribe({ event in
        print(String(describing: type(of: event)))
        print(event)
    })
    .dispose()

/// Observer 基底クラス
/// Observer = 通知を受け取る側
class Listener: NSObject {
}

/// Subject 基底クラス
class Subject<E: Listener> {

    // リスナーを保持する配列
    private(set) var listeners = Array<E>()

    /// リスナー追加
    func addListener(_ listener: E) {
        listeners.append(listener)
    }

    /// リスナー削除
    func removeListener(_ listener: E) {
        if let index = listeners.firstIndex(of: listener) {
            listeners.remove(at: index)
        }
    }
}

/// Subject 実装クラス
/// Subject = 通知を発行する側
class Influencer: Subject<Subscriber> {

    private(set) var name: String

    init(_ name: String) {
        self.name = name
    }

    /// 投稿
    func post(_ article: Article) {
        // 動画を投稿
        let url = SNSUtil.post(influencer: self, article: article)

        // チャンネル登録者に通知する
        notifyUpdate(article, url: url)
    }

    /// 変更通知
    func notifyUpdate(_ article: Article, url: String) {
        print("\(name): \(url)に投稿したよ！")
        for listener in listeners {
            listener.didUpdate(influencer: self, article: article, url: url)
        }
    }
}

/// Observer 実装クラス
class Subscriber: Listener {

    init(_ name: String) {
        self.name = name
    }

    private(set) var name: String

    func didUpdate(influencer: Influencer, article: Article, url: String) {
        print("  -> \(name): \(influencer.name)さんの「\(article.title)」みなきゃ！")

        // SNSアプリ起動
        SNSUtil.launchApp(url)
    }
}

/// 投稿内容 クラス
class Article {

    init(_ title: String) {
        self.title = title
    }

    private(set) var title: String
}

/// SNS ユーティリティクラス
class SNSUtil {

    static func post(influencer: Influencer, article: Article) -> String {
        return "https://www.twitttter.com/\(influencer.name)/\(article.title)"
    }

    static func launchApp(_ url: String) {
        // Youtubeアプリを起動してURLの動画を開く処理とか
    }
}

// インフルエンサー
let maezawa = Influencer("前澤社長")
let horiemon = Influencer("ホリエモン")

// フォロワー
let tanaka = Subscriber("田中")
let suzuki = Subscriber("鈴木")
let yamada = Subscriber("山田")

// フォロー
maezawa.addListener(tanaka)
maezawa.addListener(suzuki)
maezawa.addListener(yamada)
horiemon.addListener(tanaka)
horiemon.addListener(suzuki)
horiemon.addListener(yamada)

// 動画投稿
maezawa.post(Article("maezawa_tsukiryokou"))
horiemon.post(Article("horiemon_livedoor_collapse"))

// チャンネル登録解除
maezawa.removeListener(tanaka)
horiemon.removeListener(yamada)

// 動画投稿
maezawa.post(Article("hikakin_okanekubari"))
horiemon.post(Article("yakinikuyasan"))

// 以下オペレーターのサンプル
func createSample() {

    let disposeBag = DisposeBag()

    // マニュアルなObservableの作成
    let observable = Observable<String>
        .create({ observer in
            observer.onNext("🍺")
            observer.onNext("🍶")
            observer.onNext("🍷")
            observer.onCompleted()

            return Disposables.create {
                print("Observable: Dispose")
            }
        })

    // Observer購読
    observable
        .subscribe(onNext: { element in
            print("Observer: \(element)")
        }, onDisposed: {
            print("Observer: onDisposed")
        })
        .disposed(by: disposeBag)
}

createSample()

func deferredSample() {

    let disposeBag = DisposeBag()
    var count = 0

    // Observer毎に作られるObservableの作成
    let observable = Observable<Date>.deferred({
        count += 1
        print("Create Observable: \(count)")
        return Observable<Date>.just(Date())
    })

    // Observer購読1
    observable
        .subscribe(onNext: { element in
            print("Observer1: \(element)")
        })
        .disposed(by: disposeBag)

    // 2秒待つ
    Thread.sleep(until: Date(timeIntervalSinceNow: 2))

    // Observer購読2
    observable
        .subscribe(onNext: { element in
            print("Observer2: \(element)")
        })
        .disposed(by: disposeBag)
}

deferredSample()

func timerSample() {

    // 一定時間後に発行するObservableの作成
    let observable = Observable<Int>
        .timer(.seconds(3), scheduler: MainScheduler.instance)

    print(Date())

    // Observer購読
    _ = observable
        .subscribe(onNext: { element in
            print("Observer: \(element), Date: \(Date())")
        })
}

timerSample()

func intervalSample() {

    // 一定間隔で発行するObservableの作成
    let observable = Observable<Int>
        .interval(.seconds(2), scheduler: MainScheduler.instance)

    print(Date())

    // Observer購読
    _ = observable
        .subscribe(onNext: { element in
            print("Observer: \(element), Date: \(Date())")
        })
}

intervalSample()

func takeUntilSample() {

    // 一定時間後に発行するObservableの作成
    let timerObservable = Observable<Int>
        .timer(.seconds(5), scheduler: MainScheduler.asyncInstance)

    print(Date())

    // Observer購読
    _ = timerObservable
        .subscribe({ event in
            print("Timer Observer: \(event), Date: \(Date())")
        })

    // 一定間隔で発行するObservableの作成
    let observable = Observable<Int>
        .interval(.seconds(1), scheduler: MainScheduler.asyncInstance)
        .take(until: timerObservable)

    // Observer購読
    _ = observable
        .subscribe({ event in
            print("Observer: \(event), Date: \(Date())")
        })
}

takeUntilSample()

