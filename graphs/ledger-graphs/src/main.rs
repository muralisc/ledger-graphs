use chrono::{DateTime, Utc};
use std::fs;
use std::io::Write;
use std::process::{Command, Stdio};

fn gnuplot(code: &str) {
    let mut child = Command::new("gnuplot")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .expect("ls command failed to start");

    let child_stdin = child.stdin.as_mut().unwrap();
    child_stdin
        .write_all(code.as_bytes())
        .expect("Failed to write to stdin");

    let output = child.wait_with_output().expect("Failed to read stdout");
    let stdout_v = String::from_utf8_lossy(&output.stdout).to_string();

    println!("output = {:?}", stdout_v);
}

fn main() {
    let now: DateTime<Utc> = Utc::now();
    let formatted_date = now.format("%Y-%m-%d %H:%M:%S").to_string();

    println!("Formatted date: {}", formatted_date);

    fs::create_dir_all("/var/tmp/test_rust").expect("Directory creation failed");

    let code = r#"
set terminal pngcairo size 1750,900 enhanced font 'Verdana,10'
set output "ledger_projection.png"
set title "Simple Plots" font ",20"
set key left box
set samples 50
set style data points

plot [-10:10] sin(x),atan(x),cos(atan(x))
"#;
    gnuplot(code);
}
