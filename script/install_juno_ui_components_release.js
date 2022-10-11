/* eslint-disable no-undef */

// load remote tgz file (in target folder)
child_process.execFileSync(
  "wget",
  [
    "https://github.com/sapcc/juno/releases/download/v0_6_0/juno-ui-components.tar.gz",
  ],
  { cwd: execEnv.buildDir }
)

// extract the file (in target folder)
child_process.execFileSync("tar", ["xzf", "juno-ui-components.tar.gz"], {
  cwd: execEnv.buildDir,
})

// cleanup
child_process.execFileSync("rm", ["juno-ui-components.tar.gz"], {
  cwd: execEnv.buildDir,
})
