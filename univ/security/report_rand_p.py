#!/usr/bin/env python3

import hashlib
import time
import os
import base64
import multiprocessing

# 難易度設定 (2**24)
K = 32


def generate_raw_random_string(length=16):
    """プロセスごとに独立した乱数を生成"""
    random_bytes = os.urandom(length)
    return base64.urlsafe_b64encode(random_bytes).decode("utf-8")[:length]


def mining_worker(found_event, result_queue):
    """
    各プロセスで実行されるマイニングループ
    """
    while not found_event.is_set():
        # 1000回ごとにフラグをチェック（オーバーヘッド削減）
        for _ in range(1000):
            iv = generate_raw_random_string(16)
            hv = hashlib.sha256(iv.encode()).hexdigest()

            # 条件判定
            if int(hv, 16) % (2**K) == 0:
                # 発見した場合、イベントをセットして他プロセスに知らせる
                if not found_event.is_set():
                    found_event.set()
                    result_queue.put((iv, hv))
                return


def main():
    # 使用するプロセス数（CPUのコア数）
    num_processes = multiprocessing.cpu_count()
    print(f"Starting mining with {num_processes} processes...")

    found_event = multiprocessing.Event()
    result_queue = multiprocessing.Queue()

    processes = []
    ts = time.perf_counter()

    # プロセスの起動
    for _ in range(num_processes):
        p = multiprocessing.Process(
            target=mining_worker, args=(found_event, result_queue)
        )
        p.start()
        processes.append(p)

    # 結果を待機
    nonce, hv = result_queue.get()
    te = time.perf_counter()

    # 全プロセスの終了処理
    for p in processes:
        p.join()

    print("-" * 30)
    print("nonce =", nonce)
    print("hash  =", hv)
    print("time  =", te - ts)
    print("-" * 30)


if __name__ == "__main__":
    main()
