import os
import yaml
import subprocess

def load_config():
    script_dir = os.path.dirname(os.path.realpath(__file__))
    yaml_path = os.path.join(script_dir, "build_config.yaml")
    with open(yaml_path, "r") as f:
        return yaml.safe_load(f)

def compile_sources(config):
    srcs = [
        config['paths']['package'],
        config['paths']['interface'],
        config['paths']['reg_if'],
        config['paths']['rtl'],
        config['paths']['top']
    ]
    
    vlog_cmd = ['vlog'] + srcs
    vlog_cmd += config['compile']['extra_files']
    
    for incdir in config['compile']['incdirs']:
        vlog_cmd.append(f"+incdir+{incdir}")
    
    ccflags = ' '.join(config['compile']['ccflags'])
    vlog_cmd += ['-ccflags', f'"{ccflags}"']
    
    print("Running compile command:\n", " ".join(vlog_cmd))
    subprocess.run(" ".join(vlog_cmd), shell=True, check=True)

def simulate(config):
    testname = config['sim']['testname']
    seed = config['sim']['seed']
    waves = config['sim']['waves']

    # Optimization step
    subprocess.run("vopt work.tb_top -o tb_opt +acc=rn", shell=True, check=True)

    # Build vsim command
    if waves == 1:
        sim_cmd = (
            f"vsim -c work.tb_opt -sv_seed {seed} -l run.log "
            f'-do "add wave -r /*; run -all; quit;" +UVM_TESTNAME={testname}'
        )
    else:
        sim_cmd = (
            f"vsim -c work.tb_opt -sv_seed {seed} -l run.log "
            f'-do "run -all; quit;" +UVM_TESTNAME={testname}'
        )

    print("Running simulation command:\n", sim_cmd)
    subprocess.run(sim_cmd, shell=True, check=True)

def main():
    config = load_config()
    compile_sources(config)
    simulate(config)
    print("Simulation finished successfully.")

if __name__ == "__main__":
    main()
