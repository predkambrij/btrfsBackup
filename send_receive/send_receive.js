//#! /usr/bin/env node
var childProcess = require('child_process')
var util = require("util");
var fs = require('fs')
var read = require('read')
var config = require('./config');
//var program = require('commander');


function run() {
    checkConfig();
    process.chdir(config.working_dir);
    
    if (config.password == "") {
        read({ prompt: 'Password: ', silent: true }, function(er, password) {
            run_further(password);
        });
    } else {
        run_further(config.password);
    }
}
function checkConfig() {
    if (!(config.subvols && config.subvols.length >= 1)) {
        report_exit(1, "config: invalid subvolume list");
    }
    if (!(config.password)) {
        report_exit(1, "config: password must be at least empty string");
    }
    if (!(config.device)) {
        report_exit(1, "config: set the device");
    }
    if (!(config.working_dir)) {
        report_exit(1, "config: set the working directory");
    }
    
}

function run_further(password) {
    // go over all subvolumes
    for (var i=0; i<config.subvols.length; i++) {
        console.log("subvolume: "+config.subvols[i]);
        // get all of the snapshots to transfer for current subvolume
        var snapshots = run_remote(password, "cat /ssd/maint_snps/"+config.subvols[i]+"_list", 10);
        console.log("snapshots: "+snapshots.length);
        
        for (var snpn=0; snpn<snapshots.length; snpn++) {
            incremental_send(snapshots[snpn], config.subvols[i], password, 10);
            console.log(""); // new line
            
            //break; // TODO just one
        }
    }
}
function incremental_send(snp, subvol, password, debug) {
    var parent = parent_subvol_path(snp, subvol, 0);
    console.log("parent: "+parent);
    console.log("snapshot: "+snp);
    
    
    if (debug >= 1) {
        console.log("sending the snapshot");
    }
    btrfs_send_rec(password, parent, snp, 100);
    
    
    var list_file = "/ssd/maint_snps/"+subvol+"_list";
    if (debug >= 1) {
        console.log("removing the first entry in "+list_file);
    }
    var res = run_remote(password, "sed -i -e 1d "+list_file+";echo END\$?",10);
    if (!(res.length == 1 && res[0]=="END0")) {
        report_exit(1, "incremental_send: removing the first entry in "+list_file+" failed "+util.inspect(res));
    }
    
    
    
    var toremove_file = "/ssd/maint_snps/"+subvol+"_toremove";
    if (debug >= 1) {
        console.log("adding the snapshot "+parent+" to "+toremove_file);
    }
    var res = run_remote(password, "echo \""+parent+"\" >> "+toremove_file+";echo END\$?", 10);
    if (!(res.length == 1 && res[0]=="END0")) {
        report_exit(1, "incremental_send: addint entry to toremove failed "+util.inspect(res));
    }
    
    var parent_file = "/1t_btrfs/"+config.device+"/"+subvol+"_last_time";
    if (debug >= 1) {
        console.log("updating parent file "+parent_file+" to "+snp);
    }
    update_parent(snp, parent_file, subvol, 0);
    
    
}
function update_parent(newparent, parent_file, subvol, debug) {
    // get parent subvolume
    var command = "echo \""+newparent+"\" > "+parent_file;
    var p = childProcess.spawnSync("bash", ["-c", command], { encoding: 'utf8' });
    
    if (debug > 1) {
        console.log(p.stdout);
        console.log(p.stderr);
        console.log(p.status);
    }
    
    if (p.status != 0) {
        report_exit(1, "updating parent failed");
    }
}
function parent_subvol_path(snp, subvol, debug) {
    var device = config.device;
    // get parent subvolume
    var command = "echo /ssd/$(cat /1t_btrfs/"+device+"/"+subvol+"_last_time)";
    var p = childProcess.spawnSync("bash", ["-c", command], { encoding: 'utf8' });
    
    if (debug > 1) {
        console.log(p.stdout);
        console.log(p.stderr);
        console.log(p.status);
    }
    
    if (p.status != 0) {
        report_exit(1, "checking for parrent subvolume failed");
    }
    var parent_subvl_path = p.stdout.trim();
    //console.log(util.inspect(parent_subvl_path));
    return parent_subvl_path;
}

function run_remote(pw, cmd, debug) {
//debug=10
    pw += "\r";
    // process.chdir('/home/loj/h/newhacks/misc-scripts/btrfs_man');
    process.chdir('/home/loj/doing1/docker_host2/btrfs_man/send_receive');
    
    cmd = "echo XYXY;"+cmd+";echo XYXY;";
    var command = ("expect -c \""
         +"spawn ./run_remote.sh \\\""+cmd+"\\\"\n"
         +"expect \\\"acih\\\"\n"
         +"send \\\""+pw+"\\r\\\"\n"
         +"interact\n"
         +"\"");
    command = "script -c '"+command+"' /dev/null | grep -v 'Script started, file is /dev/null' | grep -v 'Script done, file is /dev/null'";
console.log(command)
    //console.log(command)
    var p = childProcess.spawnSync("bash", ["-c", command], { encoding: 'utf8' });

    var lines = p.stdout.split('\r\n');
    var cmd_output_lines = [];
    var adding_flag = 0;
    for(var i = 0; i < lines.length; i++){
        //console.log(util.inspect(lines[i]));
       console.log("line... "+lines[i]) 
        if ((lines[i] == "^@XYXY" || lines[i] == "XYXY") && adding_flag==0) {
            adding_flag=1;
            continue;
        } else if (lines[i] == "XYXY" && adding_flag==1) {
            adding_flag=0;
        }
        if (adding_flag == 1) {
            cmd_output_lines.push(lines[i]);
        }
    }
    if (debug > 2) {
        console.log(p.stderr);
        //console.log(p.stdout);
        console.log(p.status);
        console.log("output:");
        console.log(cmd_output_lines.join("\n"));
    }
    
    return cmd_output_lines;
}



function btrfs_send_rec(pw, parentss, ss, verb) {
    pw += "\r";
    ss = config.server_side_dir_prefix+ss;
    
    var command = ("expect -c \""
         +"spawn ./btrfs_send_rec.sh \\\""+parentss+"\\\"  \\\""+ss+"\\\"\n"
         +"expect \\\"acih\\\"\n"
         +"send \\\""+pw+"\\r\\\"\n"
         +"interact\n"
         +"\"");
    command = "script -c '"+command+"' /dev/null | grep -v 'Script started, file is /dev/null' | grep -v 'Script done, file is /dev/null'";

    //console.log(command) // HERE
    var p = childProcess.spawnSync("bash", ["-c", command], { encoding: 'utf8' });

    var lines = p.stdout.split('\r\n');
    var exit_stat = -1;
    for(var i = 0;i < lines.length;i++){
        //console.log(util.inspect(lines[i]));
        if (verb >= 1) {
            console.log(lines[i]);
        }
        
        if (lines[i].indexOf("END") == 0) {
            exit_stat = lines[i].substring(3);
        }
        
        if (lines[i].indexOf("command not found") >= 0) {
            exit_stat = -99;
            break;
        }
        if (lines[i].indexOf("ERROR") >= 0) {
            exit_stat = -99;
            break;
        }
        
    }
    if (verb >= 2) {
        console.log(p.stdout);
        console.log(p.stderr);
        console.log(p.status);
    }
    if (exit_stat != 0) {
        report_exit(1, "btrfs_send_rec: exit status "+exit_stat+" "+p.stdout+" "+p.stderr+" "+p.status);
    }
}



function report_exit(exitcode, msg) {
    exitcode = typeof exitcode !== 'undefined' ? exitcode : 1;
    msg = typeof msg !== 'undefined' ? msg : "";
    console.log("exit num "+exitcode+" "+msg);
    process.exit(exitcode);
}

if (process.getuid() != 0) {
    console.log("you must be root");
    process.exit(1);
}
run();




