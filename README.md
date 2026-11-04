# TWRP para o ASUS Zenfone Max Shot / Max Plus M2 (ZB634KL, ASUS_A001D)

Device tree do TWRP 3.7.0 (branch `twrp-11`) para o ZB634KL, com três opções de kernel.

| Item | Valor |
|---|---|
| SoC | SDM450 (família msm8953), `msm-id` 338, `board-id` 0xb |
| Android de origem | 9, com criptografia FDE |
| Partições | Sem A/B, sem partições dinâmicas, `/system` não é system-as-root |
| Tela | 1080x2280 |
| Partição `recovery` | 64 MiB |

O `twrp-11` foi escolhido porque o `android-12.1` removeu o suporte a FDE, que este aparelho usa.

## Estado

Nenhuma imagem foi instalada na partição `recovery`. Todos os testes foram feitos com
`fastboot boot`, em um único ASUS_A001D_1 com painel TCL.

| | 4.9.227 | 6.19.5 | 3.18 stock (binário anterior) |
|---|---|---|---|
| Tela | Ok | Ok | Ok |
| Touch | Ok, de primeira | Ok | Só depois de bloquear e desbloquear a tela |
| adb como root | Ok, ~17 s | Ok, ~45 s | Ok |
| MTP no Windows | Ok | Ok | Ok |
| Porcentagem e status da bateria | Ok | Ok | Ok |
| `reboot bootloader` | Ok | Ok | Ok |
| Descriptografia da `/data` | Não | Não | Não |

O 4.9 é a versão recomendada no momento.

A tabela vem das imagens de 02/11/2026, com kernels compilados à parte. Os kernels 4.9 e 6.19 de agora usam a
mesma fonte e a mesma config. **O 3.18 agora é compilado da fonte (3.18.140) e nunca foi testado no aparelho**,
e a coluna acima descreve o binário stock (3.18.120), que não é mais usado.

## Limitações

Valem para todas as versões:

- **A `/data` não monta.** A descriptografia não está ativa e os blobs de FDE não estão neste
  repositório. **Não use "Format Data"**, porque isso apaga os dados do aparelho.
- **O uso real não foi testado:** backup, restauração, instalação de zip, microSD e USB OTG.
- **`Reboot` → `Recovery` não foi testado até o fim** em nenhuma versão. O teste inicia o kernel gravado na partição
  `recovery`, que pode gravar firmware de touch se for de outra origem. Confira esse kernel antes.
- **Instalação permanente não foi testada.**
- O ajuste de tela para o notch não foi feito (`TW_Y_OFFSET`).
- Só um aparelho foi testado. O ASUS_A001D_2 e os painéis Boyi e Holitech não foram testados.

Limitações específicas de cada kernel estão no `README.A001D.md` de cada um:
[4.9](../../../kernel/asus/msm8953-4.9/README.A001D.md) e
[6.19](../../../kernel/asus/msm8953-6.19/README.A001D.md).

No binário 3.18 stock, o touch só respondia depois de bloquear e desbloquear a tela, com erros
`i2c -107` no boot. Ainda não se sabe se isso ocorre no 3.18 compilado da fonte.

## Compilar

O kernel é sempre compilado da fonte pelo próprio build. Requer o manifesto mínimo `twrp-11`, este repositório em
`device/asus/A001D` e os kernels em `kernel/asus/`.

```bash
source build/envsetup.sh
lunch twrp_A001D-eng
make recoveryimage                     # kernel 4.9, o padrão
A001D_KERNEL=6.19 make recoveryimage   # ou 3.18
```

A imagem sai em `$OUT/recovery.img`.

| `A001D_KERNEL` | Fonte | Config | Compilador |
|---|---|---|---|
| `4.9` (padrão) | `kernel/asus/msm8953-4.9` | `a001d_twrp_defconfig` | clang r383902 da árvore |
| `6.19` | `kernel/asus/msm8953-6.19` | `a001d_twrp_defconfig` | `gcc-aarch64-linux-gnu` do sistema |
| `3.18` | `kernel/asus/a001d-3.18` | `A001D_defconfig` | GCC 4.9 do Android 9, por local manifest |

O android-11 removeu o GCC, e o 3.18 precisa dele. Crie `.repo/local_manifests/a001d.xml` e rode
`repo sync prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9-gcc`:

```xml
<manifest>
  <project path="prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9-gcc"
           name="platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9"
           remote="aosp" revision="refs/tags/android-9.0.0_r61" clone-depth="1" />
</manifest>
```

Ao trocar de versão, o `AndroidBoard.mk` apaga o `KERNEL_OBJ`, então o kernel é refeito do zero.

Todo `make recoveryimage` roda o Kbuild, que recompila só o que mudou na fonte do kernel. Por isso, mesmo sem alterações,
o comando refaz o kernel e a imagem, e o hash da imagem muda.

O cabeçalho das imagens usa os valores da stock (Android 9.0.0, patch 2020-06), para não afetar a verificação de
versão do keymaster.

## Testar sem gravar nada

```bash
adb reboot bootloader
fastboot boot twrp-A001D-k4.9.img
```

Se travar, **Energia + Volume para cima** leva ao fastboot, e Energia sozinho por 15 s reinicia
no Android. Nada é gravado em `boot` ou `recovery` durante esse teste. O TWRP monta o `/cache`
para escrita e grava logs nele.

## Segurança do touch

Um kernel de outro aparelho já gravou firmware errado no touch deste telefone. Nenhum kernel pode ter caminho de
gravação de firmware de touch.

O `check_kernel.sh` roda dentro do `make recoveryimage`, para todas as versões, e o build para se encontrar símbolos
de upgrade ou firmware embutido, ou se o driver de touch não estiver no kernel. **Não remova essa verificação.**

A fonte original do 3.18 tem `FTS_AUTO_UPGRADE_EN 1` e firmware de exemplo do FT8716, então compilá-la sem alterações
é perigoso. O patch que remove a gravação do 4.9 foi aplicado nela também.

Antes de instalar, faça um backup da partição `recovery` atual.

