import yt
import numpy as np
import matplotlib.pyplot as plt
import glob
import os
from unyt import Mpc, km, s, K, g, cm

# --- Configuration ---
base_dir = "/data/mfulghieri/enzo-dev/run/Cosmology/ZeldovichPancake"

# Path of the plotfiles. data???? not to load .boundary o .hierarchy
plotfiles = sorted(glob.glob(os.path.join(base_dir, "DD????/data????")))

if not plotfiles:
    print("Error: no Enzo output found!")
    exit(1)

# Select only some redshifts (e. g. 6 steps)
indices = np.linspace(0, len(plotfiles) - 1, 6, dtype=int)
selected_files = [plotfiles[i] for i in indices]

fig, axes = plt.subplots(3, 1, figsize=(10, 14), sharex=False)
plt.subplots_adjust(hspace=0.05)

# Colormap to distinguish different times
colors = plt.cm.plasma(np.linspace(0, 0.8, len(selected_files)))

for i, plt_file in enumerate(selected_files):
    try:
        ds = yt.load(plt_file)
        z = ds.current_redshift
        a = 1.0 / (1.0 + z)
        h = ds.hubble_constant        
        # 1D ray
        ray = ds.ray(ds.domain_left_edge, ds.domain_right_edge)
        sort_idx = np.argsort(ray['x'])
        x_mpc = ray['x'][sort_idx].to('Mpccm/h').value   # Mpc/h: comoving Mpc 
	x_phys = (ray['x'][sort_idx].to('Mpccm/h') * a / h).to('Mpc').value

        # Density
        rho = ray["gas", "density"][sort_idx]
        overdensity = (rho / np.mean(rho)).value

        # Velocity
        v_pec = ray["gas", "velocity_x"][sort_idx].to('km/s').value

        # Temperature
        temp = ray["gas", "temperature"][sort_idx].to('K').value

        # Plotting
        label = f"z = {z:.1f}"
        axes[0].plot(x_mpc, overdensity, color=colors[i], label=label, lw=2)
        axes[1].plot(x_mpc, v_pec, color=colors[i], lw=2)
        axes[2].plot(x_mpc, temp, color=colors[i], lw=2)

# Addition of the ax of the physical coordinates        
ax_top = axes[0].twiny()
ax_top.set_xlim(axes[0].get_xlim())
# Approximate convertion for the last redshift (a=0.5, h=0.7)
ticks_h = np.linspace(0, 14, 8)
ticks_phys = ticks_h / h * 0.5 # x_phys = x_h / h * a
ax_top.set_xticks(ticks_h)
	ax_top.set_xticklabels([f"{t:.1f}" for t in ticks_phys])
	ax_top.set_xlabel("Physical Distance at $z=1$ [Mpc]", color='gray', fontsize=10)

        print(f"Success: {os.path.basename(plt_file)} | z = {z:.2f}")

    except Exception as e:
        print(f"Skip the file {plt_file} due to the error: {e}")

# --- Plot refinement ---
axes[0].set_ylabel(r"Overdensity $\rho / \bar{\rho}$")
axes[0].set_yscale('log')
axes[0].legend(title="Redshift", loc='upper right', fontsize='small')
axes[0].set_title("Zel'dovich pancake")

axes[1].set_ylabel(r"$v_{pec}$ [km/s]")
axes[1].axhline(0, color='black', lw=1, ls='--')

axes[2].set_ylabel("Temperature [K]")
axes[2].set_yscale('log')
axes[2].set_xlabel("x comoving [Mpc/h]")

for ax in axes:
    ax.grid(True, which='both', alpha=0.2)

plt.savefig("enzo_evolution_pancake.png", dpi=300, bbox_inches='tight')
print("\nPlot saved: enzo_evolution_pancake.png")
