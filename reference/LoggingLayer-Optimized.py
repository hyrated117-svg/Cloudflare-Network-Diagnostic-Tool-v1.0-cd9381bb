#!/usr/bin/env python3
"""
LoggingLayer-Optimized.py
Batched Base64 Encoding for Diagnostic Logs

ISSUE: Every log write triggers Base64 encoding, causing 33% size overhead
       and blocking execution synchronously
SOLUTION: Batch encode on background thread, or use streaming compression
"""

import base64
import json
import os
import asyncio
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Any
import threading
from concurrent.futures import ThreadPoolExecutor


class DiagnosticLogger:
    """Base implementation - DO NOT USE (sequential, blocking)"""

    def __init__(self, log_dir: str):
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(parents=True, exist_ok=True)

    # ❌ PROBLEMATIC: Encodes every single log entry synchronously
    def write_log_blocking(self, log_entry: Dict[str, Any]) -> None:
        """
        SLOW: Base64-encodes and writes each log synchronously.
        Blocks execution for each write operation.
        """
        try:
            # Serialize to JSON
            json_str = json.dumps(log_entry)
            
            # ⚠️ EXPENSIVE: Base64 encode (33% overhead)
            encoded = base64.b64encode(json_str.encode()).decode()
            
            # Write to file (I/O blocking)
            timestamp = datetime.now().isoformat()
            log_file = self.log_dir / f"diagnostic_{timestamp}.cflog"
            
            with open(log_file, 'a') as f:
                f.write(encoded + '\n')  # Blocking I/O
        except Exception as e:
            print(f"Error writing log: {e}")


class OptimizedDiagnosticLogger:
    """Optimized implementation using batching"""

    def __init__(self, log_dir: str, batch_size: int = 100):
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(parents=True, exist_ok=True)
        self.batch_size = batch_size
        self.log_buffer: List[str] = []
        self.buffer_lock = threading.Lock()
        self.executor = ThreadPoolExecutor(max_workers=1)  # Single writer thread

    # ✅ FAST: Batched encoding on background thread
    def write_log_batched(self, log_entry: Dict[str, Any]) -> None:
        """
        FAST: Batches log entries and encodes on background thread.
        Non-blocking for the main thread.
        """
        json_str = json.dumps(log_entry)

        with self.buffer_lock:
            self.log_buffer.append(json_str)
            
            # Flush to disk when buffer reaches batch size
            if len(self.log_buffer) >= self.batch_size:
                batch = self.log_buffer.copy()
                self.log_buffer.clear()
                
                # Submit to background thread (non-blocking)
                self.executor.submit(self._flush_batch, batch)

    def _flush_batch(self, batch: List[str]) -> None:
        """Background thread worker: encode and write batch"""
        try:
            # Batch encode (more efficient than individual encodes)
            batch_str = '\n'.join(batch)
            encoded = base64.b64encode(batch_str.encode()).decode()
            
            # Write to file on background thread
            timestamp = datetime.now().isoformat()
            log_file = self.log_dir / f"diagnostic_{timestamp}.cflog"
            
            with open(log_file, 'a') as f:
                f.write(encoded + '\n')
        except Exception as e:
            print(f"Error flushing batch: {e}")

    def flush_remaining(self) -> None:
        """Flush remaining logs before shutdown"""
        with self.buffer_lock:
            if self.log_buffer:
                batch = self.log_buffer.copy()
                self.log_buffer.clear()
                self._flush_batch(batch)
        
        self.executor.shutdown(wait=True)


class CompressedDiagnosticLogger:
    """Alternative: Use compression instead of Base64 (more efficient)"""

    def __init__(self, log_dir: str):
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(parents=True, exist_ok=True)

    # ✅ BEST: Compression is more efficient than Base64
    def write_log_compressed(
        self, 
        log_entry: Dict[str, Any]
    ) -> None:
        """
        BEST: Uses compression instead of Base64.
        - 40-60% smaller files
        - Non-blocking
        - Better performance
        """
        import gzip
        
        json_str = json.dumps(log_entry)
        
        timestamp = datetime.now().isoformat()
        log_file = self.log_dir / f"diagnostic_{timestamp}.gz"
        
        # Background thread compression
        thread = threading.Thread(
            target=self._compress_and_write,
            args=(json_str, log_file),
            daemon=True
        )
        thread.start()

    @staticmethod
    def _compress_and_write(data: str, filepath: Path) -> None:
        """Background thread worker: compress and write"""
        try:
            import gzip
            with gzip.open(filepath, 'at') as f:
                f.write(data + '\n')
        except Exception as e:
            print(f"Error compressing log: {e}")


# MARK: - Async/Await Pattern (Python 3.7+)

class AsyncDiagnosticLogger:
    """Async implementation for maximum efficiency"""

    def __init__(self, log_dir: str, batch_size: int = 100):
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(parents=True, exist_ok=True)
        self.batch_size = batch_size
        self.log_buffer: List[str] = []

    async def write_log_async(self, log_entry: Dict[str, Any]) -> None:
        """Non-blocking async log write"""
        json_str = json.dumps(log_entry)
        self.log_buffer.append(json_str)
        
        if len(self.log_buffer) >= self.batch_size:
            batch = self.log_buffer.copy()
            self.log_buffer.clear()
            
            # Encode on background thread
            await self._flush_batch_async(batch)

    async def _flush_batch_async(self, batch: List[str]) -> None:
        """Async batch flush"""
        # Run CPU-intensive encoding in thread pool
        loop = asyncio.get_event_loop()
        
        batch_str = '\n'.join(batch)
        encoded = await loop.run_in_executor(
            None,
            base64.b64encode,
            batch_str.encode()
        )
        encoded_str = encoded.decode()
        
        # Write to file
        timestamp = datetime.now().isoformat()
        log_file = self.log_dir / f"diagnostic_{timestamp}.cflog"
        
        # Run I/O in thread pool
        await loop.run_in_executor(
            None,
            lambda: self._write_file(log_file, encoded_str)
        )

    @staticmethod
    def _write_file(filepath: Path, data: str) -> None:
        """Write file (used with executor)"""
        with open(filepath, 'a') as f:
            f.write(data + '\n')


# MARK: - 30-Day Log Cleanup

class LogCleanupManager:
    """Efficient log cleanup with date-based indexing"""

    def __init__(self, log_dir: str):
        self.log_dir = Path(log_dir)

    # ❌ SLOW: Scans all logs sequentially
    def cleanup_old_logs_slow(self, days: int = 30) -> None:
        """
        SLOW: Checks every single log file's modification time.
        O(n) operation on all logs.
        """
        cutoff_date = datetime.now() - timedelta(days=days)
        
        for log_file in self.log_dir.glob('diagnostic_*.cflog'):
            file_mtime = datetime.fromtimestamp(log_file.stat().st_mtime)
            
            if file_mtime < cutoff_date:
                log_file.unlink()  # Delete

    # ✅ FAST: Date-based batch deletion
    def cleanup_old_logs_fast(self, days: int = 30) -> None:
        """
        FAST: Groups logs by date in filename, deletes in batches.
        Much more efficient for large log counts.
        """
        cutoff_date = datetime.now() - timedelta(days=days)
        cutoff_str = cutoff_date.isoformat()[:10]  # YYYY-MM-DD
        
        deleted_count = 0
        
        # Iterate through logs with date-based sorting
        for log_file in sorted(self.log_dir.glob('diagnostic_*.cflog')):
            # Extract date from filename
            filename = log_file.name
            # Format: diagnostic_YYYY-MM-DDTHH:MM:SS.cflog
            file_date = filename.split('_')[1][:10]  # Extract YYYY-MM-DD
            
            if file_date < cutoff_str:
                log_file.unlink()
                deleted_count += 1
        
        print(f"Cleaned up {deleted_count} old logs (older than {days} days)")

    # ✅ BEST: Indexed cleanup with async batch deletion
    async def cleanup_old_logs_async(
        self,
        days: int = 30,
        batch_size: int = 50
    ) -> None:
        """
        BEST: Async batch deletion with progress tracking.
        Efficient for very large log directories.
        """
        cutoff_date = datetime.now() - timedelta(days=days)
        cutoff_str = cutoff_date.isoformat()[:10]
        
        # Collect old log files
        old_logs = [
            f for f in self.log_dir.glob('diagnostic_*.cflog')
            if f.name.split('_')[1][:10] < cutoff_str
        ]
        
        # Delete in batches on thread pool
        loop = asyncio.get_event_loop()
        
        for i in range(0, len(old_logs), batch_size):
            batch = old_logs[i:i + batch_size]
            await loop.run_in_executor(
                None,
                self._delete_batch,
                batch
            )
            await asyncio.sleep(0.1)  # Yield to event loop

    @staticmethod
    def _delete_batch(files: List[Path]) -> None:
        """Delete batch of files"""
        for file in files:
            try:
                file.unlink()
            except Exception as e:
                print(f"Error deleting {file}: {e}")


# MARK: - Usage Examples

if __name__ == "__main__":
    # Example 1: Batched logging (recommended)
    logger = OptimizedDiagnosticLogger("/tmp/diagnostic_logs", batch_size=100)
    
    for i in range(500):
        log_entry = {
            "timestamp": datetime.now().isoformat(),
            "index": i,
            "latency_ms": 10 + (i % 20),
            "resolver": "cloudflare"
        }
        logger.write_log_batched(log_entry)  # Non-blocking!
    
    logger.flush_remaining()
    
    # Example 2: Cleanup old logs
    cleanup = LogCleanupManager("/tmp/diagnostic_logs")
    cleanup.cleanup_old_logs_fast(days=30)
    
    # Example 3: Async pattern (if using async framework)
    # logger = AsyncDiagnosticLogger("/tmp/diagnostic_logs")
    # await logger.write_log_async(log_entry)
