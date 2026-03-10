/* ============================================================ */
/* vec_C033_RESET @ c033 */
/* ============================================================ */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void vec_C033_RESET(void)

{
  char cVar1;
  byte bVar2;
  short sVar3;
  
  do {
  } while (-1 < DAT_2002);
  sVar3 = CONCAT11((char)((ushort)&stack0x0000 >> 8),0xff);
  bVar2 = 0;
  do {
    *(undefined1 *)(ushort)bVar2 = 0;
    bVar2 = bVar2 + 1;
  } while (bVar2 != 0x3e);
  bVar2 = 0x87;
  do {
    do {
      *(undefined1 *)(_DAT_0000 + (ushort)bVar2) = 0;
      bVar2 = bVar2 + 1;
    } while (bVar2 != 0);
    cVar1 = DAT_0001 + '\x01';
    _DAT_0000 = CONCAT11(cVar1,DAT_0000);
  } while (cVar1 != '\b');
  DAT_2005 = 0;
  DAT_0041 = 0;
  DAT_0042 = 0;
  DAT_2000 = 0;
  DAT_2001 = 0;
  bVar2 = 0;
  while ((&tbl_C0EB_reset_hash)[bVar2] == *(char *)(bVar2 + 0x52)) {
    bVar2 = bVar2 + 1;
    if (bVar2 == 0xf) goto bra_C0A0;
  }
  bVar2 = 0;
  do {
    *(undefined1 *)(ushort)bVar2 = 0;
    bVar2 = bVar2 + 1;
  } while (bVar2 != 0);
  bVar2 = 0;
  do {
    *(undefined1 *)(bVar2 + 0x52) = (&tbl_C0EB_reset_hash)[bVar2];
    bVar2 = bVar2 + 1;
  } while (bVar2 != 0xf);
  DAT_0064 = 1;
bra_C0A0:
  bVar2 = 0;
  DAT_003f = 0;
  DAT_0045 = 7;
  if ((DAT_0047 == '\x01') && (DAT_0046 == '\x01')) {
    do {
      _DAT_0000 = CONCAT11(DAT_0001,*(undefined1 *)(bVar2 + 0x77));
      *(undefined1 *)(bVar2 + 0x77) = *(undefined1 *)(bVar2 + 0x67);
      *(undefined1 *)(bVar2 + 0x67) = DAT_0000;
      bVar2 = bVar2 + 1;
    } while (bVar2 != 0x10);
  }
  DAT_4015 = 0x1f;
  DAT_4017 = 0xc0;
  *(undefined2 *)(sVar3 + -1) = 0xc0d4;
  sub_EE18();
  *(undefined2 *)(sVar3 + -1) = 0xc0d7;
  sub_EE40();
  DAT_0043 = 0x88;
  DAT_2000 = 0x88;
  DAT_0048 = 0xff;
  DAT_023f = 0xff;
  DAT_024b = 0xff;
  loc_C168();
  return;
}



/* ============================================================ */
/* vec_C0FA_NMI @ c0fa */
/* ============================================================ */

undefined1 vec_C0FA_NMI(undefined1 param_1)

{
  char cVar1;
  undefined1 uStack0000;
  
  DAT_2001 = 0x1e;
  DAT_2003 = 0;
  DAT_0040 = 0;
  DAT_4014 = DAT_0045;
  uStack0000 = param_1;
  sub_DDE9_write_buffer_to_ppu();
  sub_E21C_analyze_obj_ppu_pos();
  DAT_2005 = DAT_0042;
  DAT_2000 = (DAT_0047 & DAT_0046 & 1) << 1 | DAT_0043;
  DAT_4016 = 0;
  cVar1 = '\b';
  do {
    DAT_004d = DAT_004d >> 1;
    DAT_004e = DAT_004e >> 1 | ((DAT_4017 & 3) != 0) << 7;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  DAT_004f = DAT_004d;
  if ((DAT_0046 & DAT_0047) != 0) {
    DAT_004f = DAT_004e;
  }
  DAT_004b = DAT_004b + '\x01';
  if (DAT_0048 == '\0') {
    sub_EE5C_update_sound_engine();
  }
  return uStack0000;
}



/* ============================================================ */
/* vec_C167_IRQ @ c167 */
/* ============================================================ */

void vec_C167_IRQ(void)

{
  return;
}



/* ============================================================ */
/* loc_C168 @ c168 */
/* ============================================================ */

/* WARNING: Removing unreachable block (RAM,0xc170) */
/* WARNING: Removing unreachable block (RAM,0xc180) */
/* WARNING: Removing unreachable block (RAM,0xc186) */
/* WARNING: Removing unreachable block (RAM,0xc1a3) */
/* WARNING: Removing unreachable block (RAM,0xc1ae) */
/* WARNING: Removing unreachable block (RAM,0xc1d7) */
/* WARNING: Removing unreachable block (RAM,0xc1d3) */
/* WARNING: Removing unreachable block (RAM,0xc1d9) */
/* WARNING: Removing unreachable block (RAM,0xc1e2) */
/* WARNING: Removing unreachable block (RAM,0xc1e6) */

void loc_C168(void)

{
                    /* WARNING: Do nothing block with infinite loop */
                    /* WARNING: Could not recover jumptable at 0xc1f2. Too many branches */
                    /* WARNING: Treating indirect jump as call */
  do {
  } while( true );
}



/* ============================================================ */
/* sub_C21F_draw_logo_screen @ c21f */
/* ============================================================ */

void sub_C21F_draw_logo_screen(void)

{
  byte bVar1;
  char cVar2;
  
  DAT_0001 = -0x1b;
  DAT_0002 = '\x06';
  bVar1 = 0;
  do {
    DAT_0003 = '\x17';
    do {
      DAT_2007 = (&tbl_C29F_pacman_logo)[bVar1];
      bVar1 = bVar1 + 1;
      DAT_0003 = DAT_0003 + -1;
    } while (DAT_0003 != '\0');
    DAT_0001 = DAT_0001 + ' ';
    DAT_0002 = DAT_0002 + -1;
  } while (DAT_0002 != '\0');
  DAT_0000 = '\x06';
  cVar2 = '\0';
  do {
    DAT_2006 = (&tbl_C329_logo_text)[(byte)(cVar2 + 1)];
    bVar1 = cVar2 + 2;
    do {
      cVar2 = (&tbl_C329_logo_text)[bVar1];
      if (cVar2 == -1) break;
      bVar1 = bVar1 + 1;
      DAT_2007 = cVar2;
    } while (bVar1 != 0);
    cVar2 = bVar1 + 1;
    DAT_0000 = DAT_0000 + -1;
    if (DAT_0000 == '\0') {
      return;
    }
  } while( true );
}



/* ============================================================ */
/* sub_C284_set_bg_attr @ c284 */
/* ============================================================ */

void sub_C284_set_bg_attr(void)

{
  byte bVar1;
  
  DAT_2006 = 200;
  bVar1 = 0;
  do {
    DAT_2007 = (&tbl_C3A5_background_attributes)[bVar1];
    bVar1 = bVar1 + 1;
  } while (bVar1 != 0x18);
  return;
}



/* ============================================================ */
/* sub_C4EC @ c4ec */
/* ============================================================ */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void sub_C4EC(void)

{
  char cVar1;
  byte bVar2;
  
  _DAT_0000 = CONCAT11(*(undefined1 *)(DAT_0087 + 0xc5d4),(&tbl_C5D3)[DAT_0087]);
  bVar2 = 0;
  do {
    cVar1 = *(char *)(_DAT_0000 + (ushort)bVar2);
    (&DAT_024b)[bVar2] = cVar1;
    bVar2 = bVar2 + 1;
  } while (cVar1 != -1);
  if (*(char *)(_DAT_0000 + (ushort)bVar2) != '\0') {
    return;
  }
  bVar2 = (DAT_0087 - 2) * '\x04';
  cVar1 = '\x10';
  do {
    *(undefined *)(bVar2 + 0x760) = (&tbl_C688_spr_data)[bVar2];
    bVar2 = bVar2 + 1;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}



/* ============================================================ */
/* sub_C51E @ c51e */
/* ============================================================ */

void sub_C51E(void)

{
  DAT_2006 = 0xc0;
  DAT_0000 = '\x17';
  do {
    DAT_0001 = '\x1c';
    do {
      DAT_0001 = DAT_0001 + -1;
    } while (DAT_0001 != '\0');
    DAT_2007 = 0x2d;
    DAT_0000 = DAT_0000 + -1;
  } while (-1 < DAT_0000);
  return;
}



/* ============================================================ */
/* sub_C54E @ c54e */
/* ============================================================ */

void sub_C54E(void)

{
  char cVar1;
  
  cVar1 = ' ';
  do {
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  DAT_0000 = '\x03';
  do {
    cVar1 = '\b';
    do {
      cVar1 = cVar1 + -1;
    } while (cVar1 != '\0');
    DAT_0000 = DAT_0000 + -1;
  } while (DAT_0000 != '\0');
  cVar1 = '\0';
  do {
    cVar1 = cVar1 + '\x01';
  } while (cVar1 != ' ');
  DAT_2006 = 0xe8;
  DAT_2007 = 0x22;
  return;
}



/* ============================================================ */
/* sub_C7DE @ c7de */
/* ============================================================ */

void sub_C7DE(void)

{
  byte bVar1;
  
  bVar1 = 0;
  DAT_0000 = 0;
  do {
    if ((&DAT_0278)[bVar1] == '\0') break;
    DAT_0000 = DAT_0000 + 1;
    bVar1 = bVar1 + 4;
  } while (bVar1 != 0);
  (&DAT_0278)[bVar1] = 0xf4;
  (&DAT_027a)[bVar1] = 0xa8;
  *(undefined1 *)(bVar1 + 0x1e) = 0xff;
  *(undefined1 *)(bVar1 + 0x1f) = 0;
  bVar1 = DAT_0000;
  (&DAT_0293)[DAT_0000] = DAT_0089;
  (&DAT_028d)[bVar1] = 0xc;
  DAT_0089 = DAT_0089 + '\x01';
  return;
}



/* ============================================================ */
/* sub_C812 @ c812 */
/* ============================================================ */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void sub_C812(void)

{
  char cVar1;
  byte bVar2;
  byte bVar3;
  
  sub_E9A5();
  sub_C864();
  sub_C930();
  sub_C821();
  _DAT_0000 = &DAT_0274;
  _DAT_0002 = (char *)0x700;
  DAT_0004 = 0;
  do {
    DAT_0005 = '\0';
    bVar3 = 0;
    do {
      if (_DAT_0000[2] == '\0') {
        cVar1 = -1;
      }
      else {
        cVar1 = _DAT_0000[2] + (&tbl_DDC1_spr_pos)[bVar3];
      }
      *_DAT_0002 = cVar1;
      bVar2 = ((byte)(&DAT_028c)[DAT_0004] >> 7) << 1 | (byte)((&DAT_028c)[DAT_0004] << 1) >> 7;
      if (bVar2 == 0) {
        DAT_0006 = (&DAT_028c)[DAT_0004] * '\x04' + DAT_0005;
        _DAT_0002[1] = (&tbl_DB59_spr_T)[DAT_0006];
        _DAT_0002[2] = (&DAT_0292)[DAT_0004] | s_cdefgdehijkLL_dc80[DAT_0006 + 0xd];
      }
      else if (bVar2 == 2) {
        DAT_0006 = (&DAT_028c)[DAT_0004] * '\x04' + DAT_0005;
        _DAT_0002[1] = s_cdefgdehijkLL_dc80[DAT_0006 + 0xd];
        _DAT_0002[2] = (&DAT_0292)[DAT_0004] | (&tbl_DDC1_spr_pos)[DAT_0006];
      }
      else if (bVar2 < 2) {
        DAT_0006 = (&DAT_028c)[DAT_0004] * '\x04' + DAT_0005;
        _DAT_0002[1] = (&tbl_DC59_spr_T)[DAT_0006];
        _DAT_0002[2] = (&DAT_0292)[DAT_0004] | (&tbl_DD8D_spr_A)[DAT_0006];
      }
      else {
        DAT_0006 = (&DAT_028c)[DAT_0004] * '\x04' + DAT_0005;
        _DAT_0002[1] = s_cdefgdehijkLL_dc80[DAT_0006 + 0xd];
        _DAT_0002[2] = (&DAT_0292)[DAT_0004] | (&tbl_DDC1_spr_pos)[DAT_0006];
      }
      if (*_DAT_0000 == '\0') {
        cVar1 = -1;
      }
      else {
        cVar1 = *_DAT_0000 + *(char *)(bVar3 + 0xddc2);
      }
      _DAT_0002[3] = cVar1;
      _DAT_0002 = (char *)CONCAT11(DAT_0003,DAT_0002 + '\x04');
      DAT_0005 = DAT_0005 + '\x01';
      bVar3 = bVar3 + 2;
    } while (bVar3 != 8);
    _DAT_0000 = (char *)CONCAT11(DAT_0001,DAT_0000 + '\x04');
    DAT_0004 = DAT_0004 + 1;
  } while (DAT_0004 != 6);
  return;
}



/* ============================================================ */
/* sub_C821 @ c821 */
/* ============================================================ */

void sub_C821(void)

{
  ushort uVar1;
  byte bVar2;
  byte bVar3;
  
  if (DAT_001a < '\0') {
    return;
  }
  DAT_0000 = DAT_0274 + 8;
  bVar3 = 0;
  DAT_0001 = 0;
  while ((bVar2 = DAT_0001, (&DAT_0278)[bVar3] == 0 || (DAT_0000 <= (byte)(&DAT_0278)[bVar3]))) {
    DAT_0001 = DAT_0001 + 1;
    bVar3 = bVar3 + 4;
    if (bVar3 == 0x10) {
      return;
    }
  }
  DAT_008a = 0x40;
  uVar1 = (ushort)DAT_0089;
  DAT_0089 = DAT_0089 + 1;
  (&DAT_028d)[DAT_0001] = (&tbl_C924)[uVar1];
  (&DAT_0293)[bVar2] = 0;
  DAT_028c = 0;
  DAT_0276 = 0;
  return;
}



/* ============================================================ */
/* sub_C864 @ c864 */
/* ============================================================ */

void sub_C864(void)

{
  byte bVar1;
  
  DAT_0000 = DAT_001e;
  DAT_0001 = DAT_001f;
  bVar1 = 0;
  do {
    *(undefined1 *)(bVar1 + 0x1e) = *(undefined1 *)(bVar1 + 0x22);
    *(undefined1 *)(bVar1 + 0x1f) = *(undefined1 *)(bVar1 + 0x23);
    bVar1 = bVar1 + 4;
  } while (bVar1 != 0xc);
  DAT_002a = DAT_0000;
  DAT_002b = DAT_0001;
  DAT_0000 = DAT_0278;
  DAT_0001 = DAT_0279;
  DAT_0002 = DAT_027a;
  DAT_0003 = DAT_027b;
  bVar1 = 0;
  do {
    (&DAT_0278)[bVar1] = *(undefined1 *)(bVar1 + 0x27c);
    bVar1 = bVar1 + 1;
  } while (bVar1 != 0xc);
  DAT_0284 = DAT_0000;
  DAT_0285 = DAT_0001;
  DAT_0286 = DAT_0002;
  DAT_0287 = DAT_0003;
  DAT_0000 = DAT_028d;
  bVar1 = 0;
  do {
    (&DAT_028d)[bVar1] = *(undefined1 *)(bVar1 + 0x28e);
    bVar1 = bVar1 + 1;
  } while (bVar1 != 3);
  DAT_0290 = DAT_0000;
  DAT_0000 = DAT_0293;
  bVar1 = 0;
  do {
    (&DAT_0293)[bVar1] = *(undefined1 *)(bVar1 + 0x294);
    bVar1 = bVar1 + 1;
  } while (bVar1 != 3);
  DAT_0296 = DAT_0000;
  return;
}



/* ============================================================ */
/* sub_C8EE @ c8ee */
/* ============================================================ */

void sub_C8EE(void)

{
  byte bVar1;
  byte bVar2;
  
  if ((DAT_004b & 7) != 0) {
    return;
  }
  bVar1 = 0;
  bVar2 = 0;
  if ((DAT_004b & 8) != 0) {
    bVar2 = 4;
  }
  do {
    (&DAT_024b)[bVar1] = (&tbl_C928)[bVar2];
    bVar1 = bVar1 + 1;
    bVar2 = bVar2 + 1;
  } while (bVar1 != 4);
  return;
}



/* ============================================================ */
/* sub_C930 @ c930 */
/* ============================================================ */

void sub_C930(void)

{
  byte bVar1;
  bool bVar2;
  
  DAT_0000 = 0;
  if (-1 < DAT_001a) {
    DAT_0000 = 10;
  }
  DAT_00b7 = DAT_00b7 + 1;
  DAT_028c = (&tbl_C976)[(byte)((DAT_00b7 & 7) + DAT_0000)];
  if ((DAT_004b & 7) != 0) {
    return;
  }
  bVar2 = (DAT_004b & 8) != 0;
  DAT_0000 = (&tbl_C976)[(byte)(bVar2 + DAT_0000 + '\b' + CARRY1(bVar2,DAT_0000))];
  bVar1 = 0;
  do {
    if ((&DAT_028d)[bVar1] != '\0') {
      (&DAT_028d)[bVar1] = DAT_0000;
    }
    bVar1 = bVar1 + 1;
  } while (bVar1 != 4);
  return;
}



/* ============================================================ */
/* sub_CFFA @ cffa */
/* ============================================================ */

void sub_CFFA(void)

{
  bool bVar1;
  
  DAT_0000 = '\"';
  if ((DAT_0046 & DAT_0047) != 0) {
    DAT_0000 = '*';
  }
  DAT_0001 = 0x56;
  DAT_0002 = '\n';
  do {
    DAT_2006 = DAT_0001;
    DAT_0003 = '\x06';
    do {
      DAT_0003 = DAT_0003 + -1;
    } while (DAT_0003 != '\0');
    DAT_2007 = 0x2d;
    bVar1 = 0xdf < DAT_0001;
    DAT_0001 = DAT_0001 + 0x20;
    DAT_0000 = DAT_0000 + bVar1;
    DAT_0002 = DAT_0002 + -1;
  } while (DAT_0002 != '\0');
  return;
}



/* ============================================================ */
/* sub_D080 @ d080 */
/* ============================================================ */

/* WARNING: Removing unreachable block (RAM,0xd0af) */

void sub_D080(void)

{
  bool bVar1;
  byte bVar2;
  
  bVar1 = true;
  while( true ) {
    DAT_2006 = 0xc0;
    bVar2 = 0;
    do {
      DAT_2007 = *(undefined1 *)(bVar2 + 0xd0af);
      bVar2 = bVar2 + 1;
    } while (bVar2 != 0x40);
    if (!bVar1) break;
    bVar1 = false;
  }
  return;
}



/* ============================================================ */
/* sub_D0EF @ d0ef */
/* ============================================================ */

void sub_D0EF(void)

{
  undefined1 uVar1;
  byte bVar2;
  char cVar3;
  byte bVar4;
  
  if (-1 < (char)DAT_0089) {
    DAT_008a = DAT_008a + 1;
    if (DAT_008a == 0x3c) {
      DAT_008a = 0;
      DAT_0089 = DAT_0089 - 1;
      if ((char)DAT_0089 < '\0') {
        DAT_0088 = '\0';
        bVar2 = 0;
        do {
          DAT_0000 = *(byte *)(ushort)(byte)(bVar2 + 0x39) & 0xfc;
          *(byte *)(ushort)(byte)(bVar2 + 0x39) = bVar2 | DAT_0000;
          bVar2 = bVar2 + 1;
        } while (bVar2 != 4);
      }
    }
    if (DAT_0089 < 2) {
      bVar2 = 0;
      if ((DAT_008a & 8) == 0) {
        bVar2 = 5;
      }
      bVar4 = 0xff;
      do {
        bVar4 = bVar4 + 1;
      } while ((&DAT_024b)[bVar4] != -1);
      if (bVar4 == 0) {
        bVar2 = bVar2 + 1;
      }
      do {
        cVar3 = (&tbl_D205)[bVar2];
        (&DAT_024b)[bVar4] = cVar3;
        bVar4 = bVar4 + 1;
        bVar2 = bVar2 + 1;
      } while (cVar3 != -1);
    }
  }
  if (((DAT_0088 == '\0') && (DAT_00cf != -1)) && (DAT_00d1 = DAT_00d1 + '\x01', DAT_00d1 == '<')) {
    DAT_00d1 = '\0';
    DAT_00cf = DAT_00cf + -1;
    if (DAT_00cf < '\0') {
      DAT_00d0 = DAT_00d0 + 1;
      uVar1 = DAT_00d2;
      if ((DAT_00d0 & 1) != 0) {
        sub_E003();
        uVar1 = 0xf;
      }
      DAT_00cf = *(char *)(ushort)(byte)(DAT_00d0 + 0x97);
      DAT_0087 = uVar1;
    }
  }
  if ((DAT_00d3 != '\0') && ((char)(DAT_00d3 + DAT_006a) == -0x40)) {
    sub_D1EB();
    cVar3 = '\0';
    do {
      if (DAT_00d3 == *(char *)(ushort)(byte)(cVar3 + 0x8f)) {
        DAT_00d3 = *(char *)(ushort)(byte)(cVar3 + 0x90);
        break;
      }
      cVar3 = cVar3 + '\x01';
    } while (cVar3 != '\x04');
  }
  DAT_00d6 = DAT_00d6 + '\x01';
  cVar3 = '`';
  if (DAT_00d6 == '`') {
    DAT_00d6 = '\0';
    cVar3 = DAT_00d5 + '\x01';
    DAT_00d5 = cVar3;
    if (cVar3 == DAT_0096) {
      DAT_00d5 = '\0';
      cVar3 = sub_D1EB();
    }
  }
  if ((DAT_00d4 != '\x02') && (cVar3 = *(char *)(ushort)(byte)(DAT_00d4 + 0x8d), cVar3 == DAT_006a))
  {
    DAT_00d2 = 1;
    DAT_00ca = *(undefined1 *)(ushort)(byte)(DAT_00d4 * '\x02' + 0xab);
    cVar3 = *(char *)(ushort)(byte)(DAT_00d4 * '\x02' + 0xac);
    DAT_00cb = cVar3;
    DAT_00d4 = DAT_00d4 + '\x01';
  }
  if (((cVar3 != '\0' || DAT_00d7 != '\0') || DAT_00d8 != '\0') &&
     (DAT_00d8 = DAT_00d8 + -1, DAT_00d8 == '\0')) {
    if (DAT_00d7 != '\0') {
      DAT_00d7 = DAT_00d7 + -1;
      DAT_00d8 = 0x3c;
      return;
    }
    DAT_002e = DAT_00d7;
    DAT_0030 = DAT_00d7;
    DAT_008b = DAT_00d7;
  }
  return;
}



/* ============================================================ */
/* sub_D1EB @ d1eb */
/* ============================================================ */

void sub_D1EB(void)

{
  char cVar1;
  
  cVar1 = '\0';
  do {
    if (*(char *)(ushort)(byte)(cVar1 + 0xba) == '\0') {
      *(undefined1 *)(ushort)(byte)(cVar1 + 0xba) = 2;
      return;
    }
    cVar1 = cVar1 + '\x02';
  } while (cVar1 != '\x06');
  return;
}



/* ============================================================ */
/* sub_D20F @ d20f */
/* ============================================================ */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void sub_D20F(void)

{
  char cVar1;
  byte bVar2;
  byte bVar3;
  byte bVar4;
  byte bVar5;
  bool bVar6;
  
  if (DAT_006a == '\0') {
    return;
  }
  _DAT_0000 = &DAT_001e;
  DAT_0002 = 1;
  bVar2 = 0;
  do {
    if (*(char *)(ushort)(byte)(bVar2 + 0xb8) == '\x04') {
      bVar6 = true;
      bVar3 = DAT_001a;
      if (DAT_001a < *_DAT_0000) {
        bVar3 = *_DAT_0000 - DAT_001a;
        bVar4 = ~*_DAT_0000;
        bVar6 = ((DAT_001a & (bVar4 | bVar3) | bVar3 & bVar4) & 0x80) != 0;
        if (!bVar6) goto bra_D237;
      }
      else {
bra_D237:
        bVar3 = (bVar3 - *_DAT_0000) - !bVar6;
      }
      if (bVar3 < 10) {
        DAT_0003 = bVar3;
        bVar6 = true;
        bVar4 = DAT_001c;
        if (DAT_001c < _DAT_0000[2]) {
          bVar4 = _DAT_0000[2] - DAT_001c;
          bVar5 = ~_DAT_0000[2];
          bVar6 = ((DAT_001c & (bVar5 | bVar4) | bVar4 & bVar5) & 0x80) != 0;
          if (!bVar6) goto bra_D24E;
        }
        else {
bra_D24E:
          bVar4 = (bVar4 - _DAT_0000[2]) - !bVar6;
        }
        if ((bVar4 < 10) && ((byte)(bVar4 + bVar3) < 5)) {
          if (bVar2 == 8) {
            if (DAT_008b != '\0') {
              return;
            }
            DAT_00d7 = DAT_008b;
            DAT_00d8 = 0x80;
            DAT_008b = -0x80;
            DAT_0606 = 0x80;
            DAT_00dd = (&tbl_D2EB)[DAT_0093];
            DAT_00de = (&tbl_D2F3)[DAT_0093];
            DAT_0037 = (&tbl_D2DB)[DAT_0093];
          }
          else {
            if ((DAT_0002 & DAT_0088) == 0) {
              DAT_003f = 8;
              DAT_0032 = 0x12;
              DAT_00db = 0x80;
              DAT_0087 = 0;
              return;
            }
            DAT_0003 = bVar2 >> 1;
            *(undefined *)(DAT_0003 + 0x33) = (&tbl_D2D7)[DAT_00d9];
            DAT_0032 = 0;
            DAT_00dd = (&tbl_D2E7)[DAT_00d9];
            DAT_00de = (&tbl_D2E3)[DAT_00d9];
            DAT_00d9 = DAT_00d9 + 1;
            *(undefined1 *)(ushort)(byte)(bVar2 + 0xb8) = 8;
            DAT_0607 = 8;
            DAT_003f = 6;
          }
          if (DAT_0048 != '\0') {
            return;
          }
          DAT_0000 = '\x06';
          bVar6 = false;
          bVar2 = 0;
          do {
            bVar3 = bVar2;
            bVar2 = *(char *)(bVar3 + 0x70) + *(char *)(bVar3 + 0xdc) + bVar6;
            *(byte *)(bVar3 + 0x70) = bVar2;
            if (9 < bVar2) {
              *(byte *)(bVar3 + 0x70) = bVar2 - 10;
            }
            bVar6 = 9 < bVar2;
            *(undefined1 *)(bVar3 + 0xdc) = 0;
            DAT_0000 = DAT_0000 + -1;
            bVar2 = bVar3 + 1;
          } while (DAT_0000 != '\0');
          bVar2 = 0;
          DAT_0000 = '\0';
          do {
            cVar1 = sub_E148(*(undefined1 *)(bVar3 + 0x70));
            if (cVar1 != '0') goto bra_E0A5;
            (&DAT_023f)[bVar2] = 0x20;
            bVar2 = bVar2 + 1;
            bVar3 = bVar3 - 1;
          } while (bVar3 != 0);
          do {
            cVar1 = sub_E148(*(undefined1 *)(bVar3 + 0x70));
bra_E0A5:
            (&DAT_023f)[bVar2] = cVar1;
            bVar2 = bVar2 + 1;
            bVar3 = bVar3 - 1;
          } while (-1 < (char)bVar3);
          if ((DAT_006b == '\0') && (DAT_0073 == '\x01')) {
            DAT_006b = '\x01';
            DAT_0602 = 1;
            cVar1 = DAT_0067 + '\x01';
            DAT_0000 = (DAT_0067 + -1) * '\x02';
            bVar2 = 0xff;
            do {
              bVar3 = bVar2;
              bVar2 = bVar3 + 1;
            } while ((&DAT_024b)[bVar2] != -1);
            bVar4 = 0;
            DAT_0067 = cVar1;
            if (bVar2 != 0) {
              (&DAT_024b)[bVar2] = 0;
              bVar4 = bVar3 + 2;
            }
            DAT_0001 = '\0';
            if ((DAT_0046 & DAT_0047) != 0) {
              DAT_0001 = '\b';
            }
            bVar2 = 0;
            do {
              (&DAT_024b)[bVar4] = (&tbl_E13A)[bVar2] + DAT_0001;
              (&DAT_024b)[(byte)(bVar4 + 1)] = (&tbl_E13A)[(byte)(bVar2 + 1)] + DAT_0000;
              DAT_0002 = '\x03';
              bVar3 = bVar2 + 1;
              bVar5 = bVar4 + 1;
              do {
                bVar4 = bVar5;
                bVar2 = bVar3;
                bVar5 = bVar4 + 1;
                bVar3 = bVar2 + 1;
                (&DAT_024b)[bVar5] = (&tbl_E13A)[bVar3];
                DAT_0002 = DAT_0002 + -1;
              } while (DAT_0002 != '\0');
              bVar4 = bVar4 + 2;
              bVar2 = bVar2 + 2;
              DAT_0002 = 0;
            } while (bVar2 != 10);
          }
          bVar2 = 5;
          while (*(byte *)(bVar2 + 0x61) == *(byte *)(bVar2 + 0x70)) {
            bVar2 = bVar2 - 1;
            if ((char)bVar2 < '\0') {
              return;
            }
          }
          if (*(byte *)(bVar2 + 0x70) <= *(byte *)(bVar2 + 0x61)) {
            return;
          }
          bVar2 = 0;
          do {
            (&DAT_0245)[bVar2] = (&DAT_023f)[bVar2];
            bVar2 = bVar2 + 1;
          } while (bVar2 != 6);
          cVar1 = '\0';
          do {
            *(undefined1 *)(ushort)(byte)(cVar1 + 0x61) =
                 *(undefined1 *)(ushort)(byte)(cVar1 + 0x70);
            cVar1 = cVar1 + '\x01';
          } while (cVar1 != '\x06');
          return;
        }
      }
    }
    bVar2 = bVar2 + 2;
    _DAT_0000 = (byte *)(ushort)(byte)(DAT_0000 + 4);
    DAT_0002 = DAT_0002 << 1;
    if (bVar2 == 10) {
      return;
    }
  } while( true );
}



/* ============================================================ */
/* sub_D2FB @ d2fb */
/* ============================================================ */

/* WARNING: Control flow encountered bad instruction data */
/* WARNING: Instruction at (RAM,0xd01a) overlaps instruction at (RAM,0xd018)
    */
/* WARNING: Removing unreachable block (RAM,0xc170) */
/* WARNING: Removing unreachable block (RAM,0xc180) */
/* WARNING: Removing unreachable block (RAM,0xc186) */
/* WARNING: Removing unreachable block (RAM,0xc1a3) */
/* WARNING: Removing unreachable block (RAM,0xc1ae) */
/* WARNING: Removing unreachable block (RAM,0xc1d7) */
/* WARNING: Removing unreachable block (RAM,0xc1d3) */
/* WARNING: Removing unreachable block (RAM,0xc1d9) */
/* WARNING: Removing unreachable block (RAM,0xc1e2) */
/* WARNING: Removing unreachable block (RAM,0xc9e5) */
/* WARNING: Removing unreachable block (RAM,0xc9e9) */
/* WARNING: Removing unreachable block (RAM,0xc9ef) */
/* WARNING: Removing unreachable block (RAM,0xc9f6) */
/* WARNING: Removing unreachable block (RAM,0xc9fa) */
/* WARNING: Removing unreachable block (RAM,0xc9fe) */
/* WARNING: Removing unreachable block (RAM,0xc1e6) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

byte sub_D2FB(void)

{
  byte bVar1;
  undefined1 uVar2;
  byte bVar3;
  byte bVar4;
  byte bVar5;
  char cVar6;
  undefined1 *puVar7;
  bool bVar8;
  
  if (DAT_0048 == '\0') {
    if ((DAT_004f & 0xf0) != 0) {
      bVar4 = 0xff;
      bVar3 = DAT_004f & 0xf0;
      do {
        bVar4 = bVar4 + 1;
        bVar8 = -1 < (char)bVar3;
        bVar3 = bVar3 << 1;
      } while (bVar8);
      DAT_0050 = (&tbl_D46D_direction)[bVar4];
      goto loc_D311;
    }
bra_D33D:
    DAT_0050 = DAT_0051;
    bVar3 = DAT_0051;
  }
  else {
    DAT_00e3 = DAT_00e3 + -1;
    if (DAT_00e3 == '\0') {
      DAT_00e4 = DAT_00e4 + 2;
      DAT_00e3 = (&tbl_D48A)[DAT_00e4];
    }
    DAT_0050 = *(byte *)(DAT_00e4 + 0xd48b) & 3;
loc_D311:
    if ((((DAT_0050 + 2 & 3) != DAT_0051) ||
        ((bVar3 = DAT_0050, ((DAT_001a | DAT_001c) & 7) == 0 &&
         (bVar3 = DAT_0050, (*(byte *)(DAT_0050 + 0x22b) & 0xf0) != 0)))) &&
       (bVar3 = DAT_0051, (*(byte *)(DAT_0050 + 0x22b) & 0xf0) != 0)) goto bra_D33D;
  }
  DAT_0051 = bVar3;
  bVar3 = 4;
  if (DAT_0088 == '\0') {
    bVar3 = 10;
  }
  bVar4 = bVar3;
  if ((((DAT_022a != '\x01') && (DAT_022a != '\x02')) && (bVar4 = bVar3 - 2, DAT_022a != '\x03')) &&
     (DAT_022a != '\t')) {
    bVar4 = bVar3 - 4;
  }
  DAT_00b5 = *(byte *)(ushort)(byte)(bVar4 + 0x9f);
  DAT_00b6 = *(char *)(ushort)(byte)(bVar4 + 0xa0);
  bVar5 = DAT_0051 << 1;
  bVar3 = *(byte *)(bVar5 + 0xd37a);
  DAT_0010 = CONCAT11(bVar3,(&tbl_D379)[bVar5]);
  switch(bVar5) {
  case 0:
    bVar4 = 2;
    break;
  case 2:
    bVar4 = 0;
    break;
  case 4:
    bVar4 = 2;
    goto bra_D3A2;
  case 6:
    bVar4 = 0;
bra_D3A2:
    bVar8 = CARRY1(*(byte *)(ushort)(byte)(bVar4 + 0x1b),DAT_00b5);
    *(byte *)(ushort)(byte)(bVar4 + 0x1b) = *(byte *)(ushort)(byte)(bVar4 + 0x1b) + DAT_00b5;
    bRAM00cc = DAT_00b6 + bVar8;
    bVar3 = bRAM00cc;
    goto loc_D3AF;
  case 8:
  case 0x5e:
  case 0x8c:
code_r0x02a2:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 10:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xc:
  case 0x54:
  case 0x82:
code_r0x00a2:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xe:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x10:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x12:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x14:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x16:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x18:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x1a:
code_r0x1801:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x1c:
  case 0x32:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x1e:
  case 0x34:
    if (bVar3 != 0) {
      if ((DAT_0047 == 0) || (DAT_0077 == '\0')) {
        if (DAT_0067 == '\0') {
          if (DAT_0046 != '\0') {
            cVar6 = '\x0f';
            do {
              DAT_0000 = *(undefined1 *)(ushort)(byte)(cVar6 + 0x67);
              *(undefined1 *)(ushort)(byte)(cVar6 + 0x67) =
                   *(undefined1 *)(ushort)(byte)(cVar6 + 0x77);
              *(byte *)(ushort)(byte)(cVar6 + 0x77) = DAT_0000;
              cVar6 = cVar6 + -1;
            } while (-1 < cVar6);
          }
          do {
          } while( true );
        }
      }
      else {
        cVar6 = '\x0f';
        do {
          DAT_0000 = *(undefined1 *)(ushort)(byte)(cVar6 + 0x67);
          *(undefined1 *)(ushort)(byte)(cVar6 + 0x67) = *(undefined1 *)(ushort)(byte)(cVar6 + 0x77);
          *(byte *)(ushort)(byte)(cVar6 + 0x77) = DAT_0000;
          cVar6 = cVar6 + -1;
        } while (-1 < cVar6);
      }
    }
    do {
    } while( true );
  case 0x20:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x22:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x24:
    goto code_r0xf000;
  case 0x26:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x28:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x2a:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x2c:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x2e:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x30:
  case 0x90:
code_r0x00a9:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x36:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x38:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x3a:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x3c:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x3e:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x40:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x42:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x44:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x46:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x48:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x4a:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x4c:
    goto ofs_005_D405_00_up;
  case 0x4e:
    goto ofs_005_D3FB_01_left;
  case 0x50:
    goto ofs_005_D3D7_02_down;
  case 0x52:
    goto ofs_005_D3CD_03_right;
  default:
code_r0x0086:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x58:
code_r0x03a9:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x5a:
  case 0x88:
  case 0x92:
code_r0x0185:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x5c:
code_r0x06d0:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x62:
code_r0x0186:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 100:
  case 0x7a:
  case 0x94:
  case 0xaa:
code_r0x1ab5:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x66:
  case 0xac:
code_r0x6918:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x68:
  case 0x98:
code_r0x9501:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x6a:
  case 0x9a:
code_r0x291a:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x6c:
bra_D004:
    _DAT_0000 = CONCAT11(0x56,bVar5);
    bVar3 = 10;
    goto code_r0xd00c;
  case 0x6e:
code_r0xa644:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x70:
  case 0xa0:
code_r0xbd01:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x72:
  case 0xa2:
code_r0x022b:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x74:
  case 0xa4:
code_r0xf029:
    puVar7 = (undefined1 *)((short)register0x22 + 1);
    register0x22 = (BADSPACEBASE *)((short)register0x22 + 1);
    *(undefined1 *)(DAT_00f2 + (ushort)bVar5) = *puVar7;
loc_EF2E:
    do {
      *(byte *)((short)register0x22 + -1) = 0x31;
      *(byte *)((short)register0x22 + 0x10000) = 0xef;
      bVar4 = sub_F04F_get_sound_data_and_increase_pointer();
      bVar3 = DAT_00fd;
      if (bVar4 < 0xf0) {
        if (bVar4 < 0xc0) {
          *(byte *)register0x22 = bVar4;
          bVar4 = (bVar4 & 0xf0) >> 3;
          _DAT_00fe = (byte *)CONCAT11((&DAT_f075)[bVar4],(&tbl_F074)[bVar4]);
          for (bVar4 = *(byte *)register0x22 & 0xf; bVar4 != 0; bVar4 = bVar4 - 1) {
            _DAT_00fe = (byte *)CONCAT11((byte)((ushort)_DAT_00fe >> 9) | DAT_00fe << 7,
                                         DAT_00fe >> 1);
          }
          *(byte *)(DAT_00f2 + (ushort)(byte)(DAT_00fd + 4)) =
               *(byte *)(DAT_00f2 + (ushort)(byte)(DAT_00fd + 4)) & 0xf8 | DAT_00fe;
          *(char *)(DAT_00f2 + (ushort)(byte)(bVar3 + 3)) = DAT_00ff;
          if (4 < *(byte *)(DAT_00f2 + (ushort)DAT_00fd)) {
            *(byte *)(DAT_00f2 + (ushort)DAT_00fd) = *(byte *)(DAT_00f2 + (ushort)DAT_00fd) - 4;
          }
        }
        *(byte *)((short)register0x22 + -1) = 0x7a;
        *(byte *)((short)register0x22 + 0x10000) = 0xef;
        uVar2 = sub_F04F_get_sound_data_and_increase_pointer();
        *(undefined1 *)register0x22 = uVar2;
        *(undefined1 *)(DAT_00f2 + (ushort)(byte)(DAT_00fd + 7)) = *(undefined1 *)register0x22;
loc_EF84:
        do {
          do {
            bVar3 = DAT_00fd;
            bVar8 = 0xf7 < DAT_00fd;
            DAT_00fd = DAT_00fd + 8;
            DAT_00fc = DAT_00fc + 1 + bVar8;
            if (0xf < DAT_00fc) {
              return DAT_00fc;
            }
          } while (*(char *)(DAT_00f0 + (ushort)DAT_00fc) == '\0');
          if (*(char *)(DAT_00f2 + (ushort)DAT_00fd) == '\0') {
            *(undefined1 *)register0x22 =
                 *(undefined1 *)(DAT_00f4 + (ushort)(byte)(DAT_00fc * '\x02'));
            *(undefined1 *)(DAT_00f2 + (ushort)(byte)((bVar3 + 0xd) - ((char)DAT_00fc >> 7))) =
                 *(undefined1 *)register0x22;
            *(undefined1 *)register0x22 =
                 *(undefined1 *)
                  (DAT_00f4 + (ushort)(byte)((DAT_00fc * '\x02' + 1) - ((char)DAT_00fc >> 7)));
            *(undefined1 *)
             (DAT_00f2 + (ushort)(byte)(DAT_00fd + 6 + (0xfe < (byte)(DAT_00fc * '\x02')))) =
                 *(undefined1 *)register0x22;
            *(byte *)((short)register0x22 + -1) = 0xf1;
            *(byte *)((short)register0x22 + 0x10000) = 0xee;
            uVar2 = sub_F04F_get_sound_data_and_increase_pointer();
            *(undefined1 *)(DAT_00f2 + (ushort)DAT_00fd) = uVar2;
            *(byte *)((short)register0x22 + -1) = 0xf8;
            *(byte *)((short)register0x22 + 0x10000) = 0xee;
            uVar2 = sub_F04F_get_sound_data_and_increase_pointer();
            *(undefined1 *)(DAT_00f2 + (ushort)(byte)(DAT_00fd + 1)) = uVar2;
            *(byte *)((short)register0x22 + -1) = 5;
            *(byte *)((short)register0x22 + 0x10000) = 0xef;
            uVar2 = sub_F04F_get_sound_data_and_increase_pointer();
            *(undefined1 *)(DAT_00f2 + (ushort)(byte)(DAT_00fd + 2)) = uVar2;
            *(byte *)((short)register0x22 + -1) = 0x12;
            *(byte *)((short)register0x22 + 0x10000) = 0xef;
            uVar2 = sub_F04F_get_sound_data_and_increase_pointer();
            *(undefined1 *)(DAT_00f2 + (ushort)(byte)(DAT_00fd + 4)) = uVar2;
            break;
          }
          bVar3 = bVar3 + 0xf;
          cVar6 = *(char *)(DAT_00f2 + (ushort)bVar3) + -1;
          *(char *)(DAT_00f2 + (ushort)bVar3) = cVar6;
        } while (cVar6 != '\0');
        goto loc_EF2E;
      }
      bVar3 = (bVar4 & 0xf) << 1;
      _DAT_00fe = (byte *)CONCAT11((&DAT_efab)[bVar3],(&tbl_EFAA)[bVar3]);
      switch(bVar4 & 0xf) {
      default:
        *(undefined1 *)(DAT_00f0 + (ushort)DAT_00fc) = 0;
        *(undefined1 *)(DAT_00f2 + (ushort)DAT_00fd) = 0;
        goto loc_EF84;
      case 1:
        *(byte *)((short)register0x22 + -1) = 0xda;
        *(byte *)((short)register0x22 + 0x10000) = 0xef;
        uVar2 = sub_F04F_get_sound_data_and_increase_pointer();
        *(undefined1 *)register0x22 = uVar2;
        bVar3 = DAT_00fd + 1;
        *(byte *)(DAT_00f2 + (ushort)bVar3) = *(byte *)(DAT_00f2 + (ushort)bVar3) & 0x3f;
        *(byte *)(DAT_00f2 + (ushort)bVar3) =
             *(byte *)register0x22 | *(byte *)(DAT_00f2 + (ushort)bVar3);
        break;
      case 2:
        *(byte *)((short)register0x22 + -1) = 0xf2;
        *(byte *)((short)register0x22 + 0x10000) = 0xef;
        uVar2 = sub_F04F_get_sound_data_and_increase_pointer();
        *(undefined1 *)register0x22 = uVar2;
        bVar5 = DAT_00fd + 1;
        *(byte *)(DAT_00f2 + (ushort)bVar5) = *(byte *)(DAT_00f2 + (ushort)bVar5) & 0xcf;
        bVar3 = *(byte *)register0x22;
code_r0xf000:
        *(byte *)(DAT_00f2 + (ushort)bVar5) = bVar3 | *(byte *)(DAT_00f2 + (ushort)bVar5);
code_r0xf004:
        break;
      case 3:
        *(byte *)((short)register0x22 + -1) = 10;
        *(byte *)((short)register0x22 + 0x10000) = 0xf0;
        uVar2 = sub_F04F_get_sound_data_and_increase_pointer();
        *(undefined1 *)register0x22 = uVar2;
        bVar3 = DAT_00fd + 1;
        *(byte *)(DAT_00f2 + (ushort)bVar3) = *(byte *)(DAT_00f2 + (ushort)bVar3) & 0xf0;
        *(byte *)(DAT_00f2 + (ushort)bVar3) =
             *(byte *)register0x22 | *(byte *)(DAT_00f2 + (ushort)bVar3);
        break;
      case 4:
        goto ofs_018_F01F_04;
      case 5:
        *(byte *)((short)register0x22 + -1) = 0x32;
        *(byte *)((short)register0x22 + 0x10000) = 0xf0;
        uVar2 = sub_F04F_get_sound_data_and_increase_pointer();
        *(undefined1 *)register0x22 = uVar2;
        *(undefined1 *)(DAT_00f2 + (ushort)(byte)(DAT_00fd + 4)) = *(undefined1 *)register0x22;
        break;
      case 6:
        *(byte *)((short)register0x22 + -1) = 0x42;
        *(byte *)((short)register0x22 + 0x10000) = 0xf0;
        uVar2 = sub_F04F_get_sound_data_and_increase_pointer();
        *(undefined1 *)register0x22 = uVar2;
        *(undefined1 *)(DAT_00f2 + (ushort)(byte)(DAT_00fd + 1)) = *(undefined1 *)register0x22;
      }
    } while( true );
  case 0x76:
code_r0x3bf0:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x78:
  case 0xa8:
DAT_00a6:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x7c:
code_r0xfc29:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x7e:
code_r0x1a95:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x80:
code_r0x31d0:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x86:
code_r0x01a9:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x8a:
code_r0x08d0:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x96:
code_r0xe938:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0x9c:
    goto code_r0xf004;
  case 0x9e:
code_r0xa614:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xa6:
code_r0x0bf0:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xae:
code_r0x2904:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xb0:
code_r0x95fc:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xb2:
  case 0xdc:
code_r0xa51a:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xb4:
  case 0xca:
code_r0xc91a:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xb6:
code_r0x9018:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xb8:
code_r0xc90a:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xba:
code_r0xb0a9:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xbc:
code_r0xa506:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xbe:
code_r0x2938:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xc0:
code_r0x90df:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xc2:
  case 0xd8:
code_r0xa904:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xc4:
code_r0x0520:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xc6:
code_r0x8538:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 200:
code_r0xa538:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xcc:
code_r0xb00b:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xce:
code_r0xa906:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xd0:
code_r0x85bf:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xd2:
code_r0xd01a:
    cVar6 = func_0x06a9();
    goto code_r0xd01d;
  case 0xd4:
code_r0xc908:
    for (; bVar5 = bVar5 + 1, bVar4 != 4; bVar4 = bVar4 + 1) {
      bVar3 = (&tbl_C928)[bVar5];
      (&DAT_024b)[bVar4] = bVar3;
    }
    return bVar3;
  case 0xd6:
code_r0x90c0:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xda:
code_r0x850b:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xde:
code_r0x051a:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xe0:
code_r0x291c:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xe2:
code_r0xd007:
    *(byte *)(ushort)(byte)(bVar4 + 0x85) = *(byte *)(ushort)(byte)(bVar4 + 0x85) >> 1;
    bVar3 = (bVar3 | **(byte **)(ushort)(byte)(bVar4 + 0xa9)) << 1;
code_r0xd00c:
    _DAT_0002 = (byte *)(ushort)bVar3;
    do {
      DAT_2006 = DAT_0001;
      cVar6 = '\x06';
code_r0xd01d:
      DAT_0003 = cVar6;
      do {
        DAT_0003 = DAT_0003 + -1;
      } while (DAT_0003 != '\0');
      DAT_2007 = 0x2d;
      bVar4 = DAT_0000 + (0xdf < DAT_0001);
      _DAT_0000 = CONCAT11(DAT_0001 + 0x20,bVar4);
      bVar3 = DAT_0002 - 1;
      _DAT_0002 = (byte *)(ushort)bVar3;
    } while (bVar3 != 0);
    return bVar4;
  case 0xe4:
code_r0xa50c:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xe6:
code_r0xc550:
    cVar6 = ' ';
    do {
      cVar6 = cVar6 + -1;
    } while (cVar6 != '\0');
    DAT_0000 = '\x03';
    do {
      cVar6 = '\b';
      do {
        cVar6 = cVar6 + -1;
      } while (cVar6 != '\0');
      DAT_0000 = DAT_0000 + -1;
    } while (DAT_0000 != '\0');
    cVar6 = '\0';
    do {
      cVar6 = cVar6 + '\x01';
    } while (cVar6 != ' ');
    DAT_2006 = 0xe8;
    DAT_2007 = 0x22;
    return 0x22;
  case 0xe8:
code_r0xf051:
    bVar5 = *(byte *)(DAT_00f2 + (ushort)(byte)(bVar3 + 5));
    _DAT_00fe = (byte *)CONCAT11(*(undefined1 *)(DAT_00f2 + (ushort)(byte)(bVar3 + 6)),bVar5);
    bVar4 = *_DAT_00fe;
    *(byte *)(DAT_00f2 + (ushort)(byte)(bVar3 + 5)) = bVar5 + 1;
    *(char *)(DAT_00f2 + (ushort)(byte)(bVar3 + 6)) = DAT_00ff + (0xfe < bVar5);
    return bVar4;
  case 0xea:
code_r0x8506:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xec:
code_r0xe651:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xee:
code_r0xe6cc:
    DAT_2006 = 0;
    _DAT_0000 = 0x1c;
    do {
      DAT_0001 = '\x02';
      DAT_0002 = '\x1c';
      DAT_0003 = '\x02';
      do {
        while( true ) {
          for (; DAT_0001 != '\0'; DAT_0001 = DAT_0001 + -1) {
          }
          if (DAT_0002 == '\0') break;
          DAT_0002 = DAT_0002 + -1;
        }
        DAT_0003 = DAT_0003 + -1;
      } while (DAT_0003 != '\0');
      bVar3 = DAT_0000 - 1;
      _DAT_0000 = (ushort)bVar3;
    } while (bVar3 != 0);
    cVar6 = '\0';
    do {
      DAT_2007 = 0;
      cVar6 = cVar6 + '\x01';
    } while (cVar6 != '@');
    if (DAT_0087 != 2) {
      return DAT_0087;
    }
    DAT_2006 = 0x30;
    DAT_2007 = 0x5e;
    return 0x5e;
  case 0xf0:
code_r0x4ccc:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xf2:
    goto loc_D3AF;
  case 0xf4:
code_r0x0103:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xf6:
code_r0x0002:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xf8:
code_r0xe4a4:
    while ((cVar6 = bVar5 + 1, cVar6 != '\x11' || (bVar3 = DAT_0047, DAT_0047 != 0))) {
      if (cVar6 == '\x17') {
        if (bVar4 != 1) {
          return bVar3;
        }
        cVar6 = '\0';
        bVar4 = 0;
      }
      DAT_2006 = (&tbl_E4B6)[(byte)(cVar6 + 1)];
      bVar5 = cVar6 + 2;
      _DAT_0000 = CONCAT11(DAT_0001,(&tbl_E4B6)[bVar5]);
      do {
        bVar5 = bVar5 + 1;
        bVar3 = (&tbl_E4B6)[bVar5];
        cVar6 = DAT_0000 + -1;
        _DAT_0000 = CONCAT11(DAT_0001,cVar6);
        DAT_2007 = bVar3;
      } while (cVar6 != '\0');
    }
    return 0;
  case 0xfa:
code_r0xe3c6:
    while( true ) {
      _DAT_0002 = (byte *)CONCAT11(*(undefined1 *)(bVar4 + 0xe41a),DAT_0002);
      sub_E3EE();
      bVar4 = bVar4 + 2;
      cVar6 = DAT_0001 + DAT_0004;
      _DAT_0000 = CONCAT11(cVar6,DAT_0000 + CARRY1(DAT_0001,DAT_0004));
      DAT_0005 = DAT_0005 + -1;
      if (((DAT_0005 == '\x01') && (DAT_0047 == 0)) || (DAT_0005 == '\0')) break;
      _DAT_0002 = (byte *)(ushort)(byte)(&tbl_E419_score_addr)[bVar4];
      DAT_2006 = cVar6;
    }
    return 0;
  case 0xfc:
code_r0x0bd0:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xfe:
code_r0xe4e6:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  }
  bVar1 = *(byte *)(ushort)(byte)(bVar4 + 0x1b) - DAT_00b5;
  bVar3 = ~*(byte *)(ushort)(byte)(bVar4 + 0x1b);
  bVar5 = DAT_00b5 & (bVar3 | bVar1);
  *(byte *)(ushort)(byte)(bVar4 + 0x1b) = bVar1;
  bRAM00cc = (((bVar5 | bVar1 & bVar3) & 0x80) == 0) + DAT_00b6;
  bVar3 = bRAM00cc;
loc_D3AF:
  bRAM00cc = bRAM00cc - 1;
  if ((char)bRAM00cc < '\0') {
    return bVar3;
  }
  bVar5 = DAT_0051 << 1;
  bVar3 = *(byte *)(bVar5 + 0xd3c6);
  DAT_0010 = CONCAT11(bVar3,(&tbl_D3C5)[bVar5]);
  switch(bVar5) {
  case 0:
ofs_005_D405_00_up:
    bVar4 = 2;
    _DAT_0000 = 2;
    goto bra_D40D;
  case 2:
    goto ofs_005_D3FB_01_left;
  case 4:
ofs_005_D3D7_02_down:
    bVar4 = 2;
    _DAT_0000 = 0x202;
    break;
  case 6:
ofs_005_D3CD_03_right:
    bVar4 = 0;
    _DAT_0000 = 0x300;
    break;
  case 8:
  case 0x36:
    goto code_r0x00a2;
  default:
    goto code_r0x0086;
  case 0xc:
    goto code_r0x03a9;
  case 0xe:
  case 0x3c:
  case 0x46:
    goto code_r0x0185;
  case 0x10:
    goto code_r0x06d0;
  case 0x12:
  case 0x40:
    goto code_r0x02a2;
  case 0x16:
    goto code_r0x0186;
  case 0x18:
  case 0x2e:
  case 0x48:
  case 0x5e:
    goto code_r0x1ab5;
  case 0x1a:
  case 0x60:
    goto code_r0x6918;
  case 0x1c:
  case 0x4c:
    goto code_r0x9501;
  case 0x1e:
  case 0x4e:
    goto code_r0x291a;
  case 0x20:
    goto bra_D004;
  case 0x22:
    goto code_r0xa644;
  case 0x24:
  case 0x54:
    goto code_r0xbd01;
  case 0x26:
  case 0x56:
    goto code_r0x022b;
  case 0x28:
  case 0x58:
    goto code_r0xf029;
  case 0x2a:
    goto code_r0x3bf0;
  case 0x2c:
  case 0x5c:
    goto DAT_00a6;
  case 0x30:
    goto code_r0xfc29;
  case 0x32:
    goto code_r0x1a95;
  case 0x34:
    goto code_r0x31d0;
  case 0x3a:
    goto code_r0x01a9;
  case 0x3e:
    goto code_r0x08d0;
  case 0x44:
    goto code_r0x00a9;
  case 0x4a:
    goto code_r0xe938;
  case 0x50:
    goto code_r0xf004;
  case 0x52:
    goto code_r0xa614;
  case 0x5a:
    goto code_r0x0bf0;
  case 0x62:
    goto code_r0x2904;
  case 100:
    goto code_r0x95fc;
  case 0x66:
  case 0x90:
    goto code_r0xa51a;
  case 0x68:
  case 0x7e:
    goto code_r0xc91a;
  case 0x6a:
    goto code_r0x9018;
  case 0x6c:
    goto code_r0xc90a;
  case 0x6e:
    goto code_r0xb0a9;
  case 0x70:
    goto code_r0xa506;
  case 0x72:
    goto code_r0x2938;
  case 0x74:
    goto code_r0x90df;
  case 0x76:
  case 0x8c:
    goto code_r0xa904;
  case 0x78:
    goto code_r0x0520;
  case 0x7a:
    goto code_r0x8538;
  case 0x7c:
    goto code_r0xa538;
  case 0x80:
    goto code_r0xb00b;
  case 0x82:
    goto code_r0xa906;
  case 0x84:
    goto code_r0x85bf;
  case 0x86:
    goto code_r0xd01a;
  case 0x88:
    goto code_r0xc908;
  case 0x8a:
    goto code_r0x90c0;
  case 0x8e:
    goto code_r0x850b;
  case 0x92:
    goto code_r0x051a;
  case 0x94:
    goto code_r0x291c;
  case 0x96:
    goto code_r0xd007;
  case 0x98:
    goto code_r0xa50c;
  case 0x9a:
    goto code_r0xc550;
  case 0x9c:
    goto code_r0xf051;
  case 0x9e:
    goto code_r0x8506;
  case 0xa0:
    goto code_r0xe651;
  case 0xa2:
    goto code_r0xe6cc;
  case 0xa4:
    goto code_r0x4ccc;
  case 0xa6:
    goto loc_D3AF;
  case 0xa8:
    goto code_r0x0103;
  case 0xaa:
    goto code_r0x0002;
  case 0xac:
  case 0xb6:
    goto code_r0xe4a4;
  case 0xae:
    goto code_r0xe3c6;
  case 0xb0:
    goto code_r0x0bd0;
  case 0xb2:
  case 0xb4:
    goto code_r0xe4e6;
  case 0xb8:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xba:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xbc:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xbe:
                    /* WARNING: Could not recover jumptable at 0xd48d. Too many branches */
                    /* WARNING: Treating indirect jump as call */
    bVar3 = (*(code *)IRQ)();
    return bVar3;
  case 0xc0:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xc2:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xc4:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xc6:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 200:
  case 0xf0:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xca:
  case 0xf2:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xcc:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xce:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xd0:
  case 0xe4:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xd2:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xd4:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xd6:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xd8:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xda:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xdc:
  case 0xea:
    goto code_r0x1801;
  case 0xde:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xe0:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xe2:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xe6:
  case 0xf8:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xe8:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xec:
    _DAT_0000 = 0x22f;
    _DAT_0002 = &DAT_001e;
    if ((DAT_0088 != '\x0f') && (DAT_00d2 != '\0')) goto bra_E046;
    do {
      if ((*(char *)(ushort)(byte)(bVar4 + 0xb8) == '\x04') &&
         ((DAT_0004 = *(char *)(ushort)(byte)(bVar4 + 0xb9) + 2U & 3,
          ((*_DAT_0002 | _DAT_0002[2]) & 7) != 0 || ((*(byte *)(_DAT_0000 + DAT_0004) & 0xf8) == 0))
         )) {
        *(byte *)(ushort)(byte)(bVar4 + 0xb9) = DAT_0004;
      }
bra_E046:
      _DAT_0000 = CONCAT11(DAT_0001,DAT_0000 + '\x04');
      bVar3 = DAT_0002 + 4;
      _DAT_0002 = (byte *)CONCAT11(DAT_0003,bVar3);
      bVar4 = bVar4 + 2;
    } while (bVar4 != 8);
    return bVar3;
  case 0xee:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xf4:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xf6:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xfa:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xfc:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  case 0xfe:
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  }
  bVar3 = *(char *)(ushort)(byte)(bVar4 + 0x1a) + 1;
  *(byte *)(ushort)(byte)(bVar4 + 0x1a) = bVar3;
  if (((bVar3 & 4) == 0) && (bVar4 = DAT_0001, (*(byte *)(DAT_0001 + 0x22b) & 0xf0) != 0)) {
    bVar4 = DAT_0000;
    bVar3 = *(byte *)(ushort)(byte)(DAT_0000 + 0x1a) & 0xfc;
    *(byte *)(ushort)(byte)(DAT_0000 + 0x1a) = bVar3;
    if (bVar3 == 0) {
ofs_005_D3FB_01_left:
      bVar4 = 0;
      _DAT_0000 = 0x100;
bra_D40D:
      bVar3 = *(char *)(ushort)(byte)(bVar4 + 0x1a) - 1;
      *(byte *)(ushort)(byte)(bVar4 + 0x1a) = bVar3;
      if (((bVar3 & 4) != 0) && (bVar4 = DAT_0001, (*(byte *)(DAT_0001 + 0x22b) & 0xf0) != 0)) {
        bVar4 = DAT_0000;
        *(byte *)(ushort)(byte)(DAT_0000 + 0x1a) =
             *(char *)(ushort)(byte)(DAT_0000 + 0x1a) + 4U & 0xfc;
      }
    }
  }
  if ((DAT_001a < 0x18) || (0xa8 < DAT_001a)) {
    bRAM0038 = bRAM0038 | 0x20;
  }
  else {
    bRAM0038 = bRAM0038 & 0xdf;
  }
  if (DAT_001a < 0xb) {
    DAT_001a = 0xbf;
  }
  else if (0xbf < DAT_001a) {
    DAT_001a = 0xb;
  }
  bVar3 = (DAT_001a | DAT_001c) & 7;
  if ((bVar3 == 0) && (bVar3 = DAT_0050, DAT_0050 != DAT_0051)) {
    DAT_0051 = DAT_0050;
    bRAM00cc = bRAM00cc + 2;
  }
  goto loc_D3AF;
ofs_018_F01F_04:
  *(byte *)((short)register0x22 + -1) = 0x22;
  *(byte *)((short)register0x22 + 0x10000) = 0xf0;
  uVar2 = sub_F04F_get_sound_data_and_increase_pointer();
  *(undefined1 *)register0x22 = uVar2;
  register0x22 = (BADSPACEBASE *)((short)register0x22 + -1);
  bVar5 = DAT_00fd + 2;
  goto code_r0xf029;
}



/* ============================================================ */
/* sub_D4C2 @ d4c2 */
/* ============================================================ */

void sub_D4C2(void)

{
  char cVar1;
  
  cVar1 = '\0';
  DAT_0000 = '/';
  DAT_0001 = 2;
  DAT_0002 = '\x1e';
  DAT_0003 = 0;
  DAT_0004 = '\x01';
  do {
    sub_D4F2();
    DAT_0000 = DAT_0000 + '\x04';
    DAT_0002 = DAT_0002 + '\x04';
    DAT_0004 = DAT_0004 << 1;
    cVar1 = cVar1 + '\x02';
  } while (cVar1 != '\b');
  return;
}



/* ============================================================ */
/* sub_D4F2 @ d4f2 */
/* ============================================================ */

void sub_D4F2(char param_1)

{
  DAT_0010 = (code *)CONCAT11(*(undefined1 *)(*(byte *)(ushort)(byte)(param_1 + 0xb8) + 0xd502),
                              (&tbl_D501)[*(byte *)(ushort)(byte)(param_1 + 0xb8)]);
                    /* WARNING: Could not recover jumptable at 0xd4fe. Too many branches */
                    /* WARNING: Treating indirect jump as call */
  (*DAT_0010)();
  return;
}



/* ============================================================ */
/* sub_D78C @ d78c */
/* ============================================================ */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void sub_D78C(char param_1)

{
  if (*(char *)(ushort)(byte)(param_1 + 0xb8) == '\x06') {
    *(undefined1 *)(ushort)(byte)(param_1 - 0x3e) = 0;
    *(undefined1 *)(ushort)(byte)(param_1 - 0x3d) = 2;
    return;
  }
  if ((_DAT_0002[2] == 0x70) && ((0x8f < *_DAT_0002 || (*_DAT_0002 < 0x30)))) {
    *(undefined1 *)(ushort)(byte)(param_1 - 0x3e) = DAT_00b3;
    *(undefined1 *)(ushort)(byte)(param_1 - 0x3d) = DAT_00b4;
    return;
  }
  if ((DAT_0004 & DAT_0088) != 0) {
    *(undefined1 *)(ushort)(byte)(param_1 - 0x3e) = DAT_00b1;
    *(undefined1 *)(ushort)(byte)(param_1 - 0x3d) = DAT_00b2;
    return;
  }
  if (param_1 == '\0') {
    DAT_00c2 = DAT_00ca;
    DAT_00c3 = DAT_00cb;
    return;
  }
  *(undefined1 *)(ushort)(byte)(param_1 - 0x3e) = DAT_00af;
  *(undefined1 *)(ushort)(byte)(param_1 - 0x3d) = DAT_00b0;
  return;
}



/* ============================================================ */
/* sub_D87F @ d87f */
/* ============================================================ */

void sub_D87F(void)

{
  char cVar1;
  
  cVar1 = '\0';
  DAT_0000 = '/';
  DAT_0001 = 2;
  DAT_0002 = '\x1e';
  DAT_0003 = 0;
  DAT_0004 = '\x01';
  do {
    sub_D8AF();
    DAT_0000 = DAT_0000 + '\x04';
    DAT_0002 = DAT_0002 + '\x04';
    DAT_0004 = DAT_0004 << 1;
    cVar1 = cVar1 + '\x02';
  } while (cVar1 != '\b');
  return;
}



/* ============================================================ */
/* sub_D8AF @ d8af */
/* ============================================================ */

void sub_D8AF(char param_1)

{
  DAT_0010 = (code *)CONCAT11(*(undefined1 *)(*(byte *)(ushort)(byte)(param_1 + 0xb8) + 0xd8bf),
                              (&tbl_D8BE)[*(byte *)(ushort)(byte)(param_1 + 0xb8)]);
                    /* WARNING: Could not recover jumptable at 0xd8bb. Too many branches */
                    /* WARNING: Treating indirect jump as call */
  (*DAT_0010)();
  return;
}



/* ============================================================ */
/* sub_D8C9 @ d8c9 */
/* ============================================================ */

void sub_D8C9(void)

{
  char cVar1;
  byte bVar2;
  
  cVar1 = '\0';
  DAT_0000 = 0;
  do {
    if (*(char *)(ushort)(byte)(cVar1 + 0xb8) == '\x06') {
      DAT_0608 = *(char *)(ushort)(byte)(cVar1 + 0xb8);
      return;
    }
    cVar1 = cVar1 + '\x02';
  } while (cVar1 != '\b');
  if (DAT_0088 != '\0') {
    DAT_0609 = DAT_0088;
    return;
  }
  bVar2 = 0;
  if ((DAT_006a < 0x88) && (bVar2 = 1, DAT_006a < 0x42)) {
    bVar2 = 2;
  }
  *(undefined1 *)(bVar2 + 0x60a) = 1;
  return;
}



/* ============================================================ */
/* sub_D8F9 @ d8f9 */
/* ============================================================ */

void sub_D8F9(void)

{
  byte bVar1;
  
  DAT_0000 = DAT_0051 * '\x02' + '\x02';
  if ((((DAT_001a | DAT_001c) & 7) == 0) && ((*(byte *)(DAT_0051 + 0x22b) & 0xf0) != 0)) {
    bVar1 = DAT_00b7 & 3;
  }
  else {
    bVar1 = DAT_00b7 + 1;
    DAT_00b7 = bVar1;
  }
  if ((bVar1 & 7) < 6) {
    DAT_0032 = (&tbl_D931)[bVar1 & 7] + DAT_0000;
  }
  else {
    DAT_0032 = '\x01';
  }
  return;
}



/* ============================================================ */
/* sub_D937 @ d937 */
/* ============================================================ */

void sub_D937(void)

{
  char cVar1;
  
  cVar1 = '\0';
  DAT_0000 = (DAT_004b & 8) != 0;
  DAT_0001 = '\x01';
  do {
    sub_D956();
    DAT_0001 = DAT_0001 << 1;
    cVar1 = cVar1 + '\x02';
  } while (cVar1 != '\b');
  return;
}



/* ============================================================ */
/* sub_D956 @ d956 */
/* ============================================================ */

void sub_D956(char param_1)

{
  DAT_0010 = (code *)CONCAT11(*(undefined1 *)(*(byte *)(ushort)(byte)(param_1 + 0xb8) + 0xd966),
                              (&tbl_D965)[*(byte *)(ushort)(byte)(param_1 + 0xb8)]);
                    /* WARNING: Could not recover jumptable at 0xd962. Too many branches */
                    /* WARNING: Treating indirect jump as call */
  (*DAT_0010)();
  return;
}



/* ============================================================ */
/* sub_D9AB @ d9ab */
/* ============================================================ */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void sub_D9AB(void)

{
  byte bVar1;
  char cVar2;
  byte bVar3;
  byte bVar4;
  bool bVar5;
  
  bVar4 = 0x23;
  do {
    (&DAT_0274)[bVar4] = *(undefined1 *)(ushort)(byte)(bVar4 + 0x1a);
    bVar4 = bVar4 - 1;
  } while (-1 < (char)bVar4);
  _DAT_0000 = &DAT_0284;
  DAT_0003 = 8;
  DAT_0002 = 3;
  do {
    if ((DAT_0003 & DAT_0088) == 0) {
      bVar5 = true;
      bVar4 = DAT_0274;
      if (DAT_0274 < *_DAT_0000) {
        bVar4 = *_DAT_0000 - DAT_0274;
        bVar3 = ~*_DAT_0000;
        bVar5 = ((DAT_0274 & (bVar3 | bVar4) | bVar4 & bVar3) & 0x80) != 0;
        if (!bVar5) goto bra_D9DC;
      }
      else {
bra_D9DC:
        bVar4 = (bVar4 - *_DAT_0000) - !bVar5;
      }
      if (bVar4 < 0x19) {
        bVar5 = true;
        bVar3 = DAT_0276;
        if (DAT_0276 < _DAT_0000[2]) {
          bVar3 = _DAT_0000[2] - DAT_0276;
          bVar1 = ~_DAT_0000[2];
          bVar5 = ((DAT_0276 & (bVar1 | bVar3) | bVar3 & bVar1) & 0x80) != 0;
          if (!bVar5) goto bra_D9F5;
        }
        else {
bra_D9F5:
          bVar3 = (bVar3 - _DAT_0000[2]) - !bVar5;
        }
        DAT_0004 = bVar4;
        if ((bVar3 < 0x19) && ((byte)(bVar3 + bVar4) < 0x10)) {
          DAT_0003 = DAT_0274;
          DAT_0004 = DAT_0276;
          DAT_0005 = DAT_028c;
          DAT_0006 = DAT_0292;
          bVar4 = *_DAT_0000;
          *_DAT_0000 = DAT_0274;
          DAT_0274 = bVar4;
          DAT_0276 = _DAT_0000[2];
          _DAT_0000[2] = DAT_0004;
          bVar4 = DAT_0002;
          DAT_028c = (&DAT_028d)[DAT_0002];
          (&DAT_028d)[DAT_0002] = DAT_0005;
          DAT_0292 = (&DAT_0293)[bVar4];
          (&DAT_0293)[bVar4] = DAT_0006;
          goto loc_DA56;
        }
      }
    }
    _DAT_0000 = (byte *)CONCAT11(DAT_0001,DAT_0000 + -4);
    DAT_0003 = DAT_0003 >> 1;
    DAT_0002 = DAT_0002 - 1;
    if ((char)DAT_0002 < '\0') {
loc_DA56:
      sub_E154_calculate_ppu_positions();
      _DAT_0000 = &DAT_0274;
      _DAT_0002 = (char *)0x700;
      DAT_0004 = 0;
      do {
        DAT_0005 = '\0';
        bVar4 = 0;
        do {
          if (_DAT_0000[2] == '\0') {
            cVar2 = -1;
          }
          else {
            cVar2 = _DAT_0000[2] + (&tbl_DDC1_spr_pos)[bVar4];
          }
          *_DAT_0002 = cVar2;
          bVar3 = ((byte)(&DAT_028c)[DAT_0004] >> 7) << 1 | (byte)((&DAT_028c)[DAT_0004] << 1) >> 7;
          if (bVar3 == 0) {
            DAT_0006 = (&DAT_028c)[DAT_0004] * '\x04' + DAT_0005;
            _DAT_0002[1] = (&tbl_DB59_spr_T)[DAT_0006];
            _DAT_0002[2] = (&DAT_0292)[DAT_0004] | s_cdefgdehijkLL_dc80[DAT_0006 + 0xd];
          }
          else if (bVar3 == 2) {
            DAT_0006 = (&DAT_028c)[DAT_0004] * '\x04' + DAT_0005;
            _DAT_0002[1] = s_cdefgdehijkLL_dc80[DAT_0006 + 0xd];
            _DAT_0002[2] = (&DAT_0292)[DAT_0004] | (&tbl_DDC1_spr_pos)[DAT_0006];
          }
          else if (bVar3 < 2) {
            DAT_0006 = (&DAT_028c)[DAT_0004] * '\x04' + DAT_0005;
            _DAT_0002[1] = (&tbl_DC59_spr_T)[DAT_0006];
            _DAT_0002[2] = (&DAT_0292)[DAT_0004] | (&tbl_DD8D_spr_A)[DAT_0006];
          }
          else {
            DAT_0006 = (&DAT_028c)[DAT_0004] * '\x04' + DAT_0005;
            _DAT_0002[1] = s_cdefgdehijkLL_dc80[DAT_0006 + 0xd];
            _DAT_0002[2] = (&DAT_0292)[DAT_0004] | (&tbl_DDC1_spr_pos)[DAT_0006];
          }
          if (*_DAT_0000 == '\0') {
            cVar2 = -1;
          }
          else {
            cVar2 = *_DAT_0000 + *(char *)(bVar4 + 0xddc2);
          }
          _DAT_0002[3] = cVar2;
          _DAT_0002 = (char *)CONCAT11(DAT_0003,DAT_0002 + '\x04');
          DAT_0005 = DAT_0005 + '\x01';
          bVar4 = bVar4 + 2;
        } while (bVar4 != 8);
        _DAT_0000 = (byte *)CONCAT11(DAT_0001,DAT_0000 + '\x04');
        DAT_0004 = DAT_0004 + 1;
      } while (DAT_0004 != 6);
      return;
    }
  } while( true );
}



/* ============================================================ */
/* loc_DA5C @ da5c */
/* ============================================================ */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void loc_DA5C(void)

{
  char cVar1;
  byte bVar2;
  byte bVar3;
  
  _DAT_0000 = &DAT_0274;
  _DAT_0002 = (char *)0x700;
  DAT_0004 = 0;
  do {
    DAT_0005 = '\0';
    bVar3 = 0;
    do {
      if (_DAT_0000[2] == '\0') {
        cVar1 = -1;
      }
      else {
        cVar1 = _DAT_0000[2] + (&tbl_DDC1_spr_pos)[bVar3];
      }
      *_DAT_0002 = cVar1;
      bVar2 = ((byte)(&DAT_028c)[DAT_0004] >> 7) << 1 | (byte)((&DAT_028c)[DAT_0004] << 1) >> 7;
      if (bVar2 == 0) {
        DAT_0006 = (&DAT_028c)[DAT_0004] * '\x04' + DAT_0005;
        _DAT_0002[1] = (&tbl_DB59_spr_T)[DAT_0006];
        _DAT_0002[2] = (&DAT_0292)[DAT_0004] | s_cdefgdehijkLL_dc80[DAT_0006 + 0xd];
      }
      else if (bVar2 == 2) {
        DAT_0006 = (&DAT_028c)[DAT_0004] * '\x04' + DAT_0005;
        _DAT_0002[1] = s_cdefgdehijkLL_dc80[DAT_0006 + 0xd];
        _DAT_0002[2] = (&DAT_0292)[DAT_0004] | (&tbl_DDC1_spr_pos)[DAT_0006];
      }
      else if (bVar2 < 2) {
        DAT_0006 = (&DAT_028c)[DAT_0004] * '\x04' + DAT_0005;
        _DAT_0002[1] = (&tbl_DC59_spr_T)[DAT_0006];
        _DAT_0002[2] = (&DAT_0292)[DAT_0004] | (&tbl_DD8D_spr_A)[DAT_0006];
      }
      else {
        DAT_0006 = (&DAT_028c)[DAT_0004] * '\x04' + DAT_0005;
        _DAT_0002[1] = s_cdefgdehijkLL_dc80[DAT_0006 + 0xd];
        _DAT_0002[2] = (&DAT_0292)[DAT_0004] | (&tbl_DDC1_spr_pos)[DAT_0006];
      }
      if (*_DAT_0000 == '\0') {
        cVar1 = -1;
      }
      else {
        cVar1 = *_DAT_0000 + *(char *)(bVar3 + 0xddc2);
      }
      _DAT_0002[3] = cVar1;
      _DAT_0002 = (char *)CONCAT11(DAT_0003,DAT_0002 + '\x04');
      DAT_0005 = DAT_0005 + '\x01';
      bVar3 = bVar3 + 2;
    } while (bVar3 != 8);
    _DAT_0000 = (char *)CONCAT11(DAT_0001,DAT_0000 + '\x04');
    DAT_0004 = DAT_0004 + 1;
  } while (DAT_0004 != 6);
  return;
}



/* ============================================================ */
/* sub_DDC9 @ ddc9 */
/* ============================================================ */

void sub_DDC9(void)

{
  char cVar1;
  char cVar2;
  
  if ((DAT_004b & 0xf) == 0) {
    cVar2 = '\0';
    do {
      cVar1 = *(char *)(ushort)(byte)(cVar2 + 0x6c);
      if (cVar1 != '\a') {
        if (cVar1 == '\x01') {
          cVar1 = '\x02';
        }
        else {
          cVar1 = '\x01';
        }
      }
      *(char *)(ushort)(byte)(cVar2 + 0x6c) = cVar1;
      cVar2 = cVar2 + '\x01';
    } while (cVar2 != '\x04');
    return;
  }
  return;
}



/* ============================================================ */
/* sub_DDE9_write_buffer_to_ppu @ dde9 */
/* ============================================================ */

void sub_DDE9_write_buffer_to_ppu(void)

{
  char cVar1;
  byte bVar2;
  
  if (DAT_0048 == '\0') {
    if (DAT_023f != -1) {
      cVar1 = '\0';
      do {
        cVar1 = cVar1 + '\x01';
      } while (cVar1 != '\x06');
      DAT_023f = -1;
      if (DAT_0245 != -1) {
        cVar1 = '\0';
        do {
          cVar1 = cVar1 + '\x01';
        } while (cVar1 != '\x06');
        DAT_0245 = -1;
      }
    }
    if ((DAT_004b & 7) == 0) {
      cVar1 = '\0';
      if ((DAT_004b & 0x18) == 0) {
        cVar1 = '\0';
        do {
          cVar1 = cVar1 + '\x01';
        } while (cVar1 != '\x03');
      }
      else {
        do {
          cVar1 = cVar1 + '\x01';
        } while (cVar1 != '\x03');
      }
    }
  }
  bVar2 = 0;
  cVar1 = '\0';
  if ((DAT_0046 & DAT_0047) != 0) {
    bVar2 = 8;
  }
  do {
    DAT_2006 = (&DAT_ded0)[bVar2];
    DAT_2007 = *(char *)(ushort)(byte)(cVar1 + 0x6c);
    bVar2 = bVar2 + 2;
    cVar1 = cVar1 + '\x01';
  } while (cVar1 != '\x04');
  bVar2 = 0xff;
  do {
    if ((&DAT_024b)[(byte)(bVar2 + 1)] == -1) {
      DAT_024b = (&DAT_024b)[(byte)(bVar2 + 1)];
      return;
    }
    bVar2 = bVar2 + 2;
    DAT_2006 = (&DAT_024b)[bVar2];
    DAT_024b = DAT_2007;
    while( true ) {
      DAT_2007 = DAT_024b;
      bVar2 = bVar2 + 1;
      DAT_024b = (&DAT_024b)[bVar2];
      if (DAT_024b == '\0') break;
      if (DAT_024b == -1) {
        return;
      }
    }
  } while( true );
}



/* ============================================================ */
/* sub_DEDF_check_for_eating_pellets @ dedf */
/* ============================================================ */

void sub_DEDF_check_for_eating_pellets(void)

{
  byte bVar1;
  char cVar2;
  byte bVar3;
  byte bVar4;
  byte bVar5;
  bool bVar6;
  
  bVar1 = 0;
  if ((DAT_022a != '\t') && (bVar1 = 2, DAT_022a != '\x03')) {
    if ((DAT_022a != '\x01') && (DAT_022a != '\x02')) {
      return;
    }
    sub_DFC6();
    DAT_0002 = DAT_001a;
    DAT_0003 = DAT_001c;
    sub_E1DD_convert_position_to_ppu();
    cVar2 = '\0';
    if ((DAT_0003 & 7) != 0) {
      cVar2 = '\x02';
    }
    if ((DAT_0002 & 0xf) != 4) {
      cVar2 = cVar2 + '\x01';
    }
    *(undefined1 *)(ushort)(byte)(cVar2 + 0x6c) = 7;
    bVar1 = 4;
  }
  DAT_00d5 = 0;
  DAT_00d6 = 0;
  DAT_0002 = DAT_001a;
  DAT_0003 = DAT_001c;
  sub_E1DD_convert_position_to_ppu();
  bVar3 = 0xff;
  do {
    bVar5 = bVar3;
    bVar3 = bVar5 + 1;
  } while ((&DAT_024b)[bVar3] != -1);
  bVar4 = 0;
  if (bVar3 != 0) {
    (&DAT_024b)[bVar3] = 0;
    bVar4 = bVar5 + 2;
  }
  (&DAT_024b)[bVar4] = DAT_0003;
  (&DAT_024b)[(byte)(bVar4 + 1)] = DAT_0002;
  (&DAT_024b)[(byte)(bVar4 + 2)] = (&tbl_DFA6_points)[bVar1];
  (&DAT_024b)[(byte)(bVar4 + 3)] = 0xff;
  DAT_022a = 7;
  DAT_00dc = *(undefined1 *)(bVar1 + 0xdfa7);
  DAT_006a = DAT_006a - 1;
  if (DAT_006a == 0) {
    DAT_003f = 0xc;
    DAT_0087 = 0;
    DAT_004c = 0x48;
  }
  if ((DAT_006a == 0x37) || (DAT_006a == 0x86)) {
    DAT_00d7 = 10;
    DAT_00d8 = 0x3c;
    DAT_0037 = (&tbl_DFBE_fruit_id)[DAT_0093];
    DAT_003d = 3;
    DAT_002e = 0x60;
    DAT_0030 = 0x80;
  }
  *(undefined1 *)((DAT_006a & 1) + 0x604) = 1;
  if (DAT_0048 != '\0') {
    return;
  }
  DAT_0000 = '\x06';
  bVar6 = false;
  bVar1 = 0;
  do {
    bVar3 = bVar1;
    bVar1 = *(char *)(bVar3 + 0x70) + *(char *)(bVar3 + 0xdc) + bVar6;
    *(byte *)(bVar3 + 0x70) = bVar1;
    if (9 < bVar1) {
      *(byte *)(bVar3 + 0x70) = bVar1 - 10;
    }
    bVar6 = 9 < bVar1;
    *(undefined1 *)(bVar3 + 0xdc) = 0;
    DAT_0000 = DAT_0000 + -1;
    bVar1 = bVar3 + 1;
  } while (DAT_0000 != '\0');
  bVar1 = 0;
  DAT_0000 = '\0';
  do {
    cVar2 = sub_E148(*(undefined1 *)(bVar3 + 0x70));
    if (cVar2 != '0') goto bra_E0A5;
    (&DAT_023f)[bVar1] = 0x20;
    bVar1 = bVar1 + 1;
    bVar3 = bVar3 - 1;
  } while (bVar3 != 0);
  do {
    cVar2 = sub_E148(*(undefined1 *)(bVar3 + 0x70));
bra_E0A5:
    (&DAT_023f)[bVar1] = cVar2;
    bVar1 = bVar1 + 1;
    bVar3 = bVar3 - 1;
  } while (-1 < (char)bVar3);
  if ((DAT_006b == '\0') && (DAT_0073 == '\x01')) {
    DAT_006b = '\x01';
    DAT_0602 = 1;
    cVar2 = DAT_0067 + '\x01';
    DAT_0000 = (DAT_0067 + -1) * '\x02';
    bVar1 = 0xff;
    do {
      bVar3 = bVar1;
      bVar1 = bVar3 + 1;
    } while ((&DAT_024b)[bVar1] != -1);
    bVar5 = 0;
    DAT_0067 = cVar2;
    if (bVar1 != 0) {
      (&DAT_024b)[bVar1] = 0;
      bVar5 = bVar3 + 2;
    }
    DAT_0001 = '\0';
    if ((DAT_0046 & DAT_0047) != 0) {
      DAT_0001 = '\b';
    }
    bVar1 = 0;
    do {
      (&DAT_024b)[bVar5] = (&tbl_E13A)[bVar1] + DAT_0001;
      (&DAT_024b)[(byte)(bVar5 + 1)] = (&tbl_E13A)[(byte)(bVar1 + 1)] + DAT_0000;
      DAT_0002 = '\x03';
      bVar3 = bVar1 + 1;
      bVar4 = bVar5 + 1;
      do {
        bVar5 = bVar4;
        bVar1 = bVar3;
        bVar4 = bVar5 + 1;
        bVar3 = bVar1 + 1;
        (&DAT_024b)[bVar4] = (&tbl_E13A)[bVar3];
        DAT_0002 = DAT_0002 + -1;
      } while (DAT_0002 != '\0');
      bVar5 = bVar5 + 2;
      bVar1 = bVar1 + 2;
      DAT_0002 = 0;
    } while (bVar1 != 10);
  }
  bVar1 = 5;
  while (*(byte *)(bVar1 + 0x61) == *(byte *)(bVar1 + 0x70)) {
    bVar1 = bVar1 - 1;
    if ((char)bVar1 < '\0') {
      return;
    }
  }
  if (*(byte *)(bVar1 + 0x70) <= *(byte *)(bVar1 + 0x61)) {
    return;
  }
  bVar1 = 0;
  do {
    (&DAT_0245)[bVar1] = (&DAT_023f)[bVar1];
    bVar1 = bVar1 + 1;
  } while (bVar1 != 6);
  cVar2 = '\0';
  do {
    *(undefined1 *)(ushort)(byte)(cVar2 + 0x61) = *(undefined1 *)(ushort)(byte)(cVar2 + 0x70);
    cVar2 = cVar2 + '\x01';
  } while (cVar2 != '\x06');
  return;
}



/* ============================================================ */
/* sub_DFC6 @ dfc6 */
/* ============================================================ */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void sub_DFC6(void)

{
  char cVar1;
  byte bVar2;
  byte bVar3;
  
  DAT_0089 = DAT_008c;
  if (DAT_008c == '\0') {
    DAT_008a = 0x1e;
    DAT_0089 = '\0';
  }
  DAT_0088 = '\x0f';
  cVar1 = '\x03';
  do {
    *(byte *)(ushort)(byte)(cVar1 + 0x39) = *(byte *)(ushort)(byte)(cVar1 + 0x39) & 0xfc | 1;
    cVar1 = cVar1 + -1;
  } while (-1 < cVar1);
  bVar3 = 0xff;
  do {
    bVar3 = bVar3 + 1;
  } while ((&DAT_024b)[bVar3] != -1);
  bVar2 = 0;
  if (bVar3 == 0) {
    bVar2 = 1;
  }
  do {
    cVar1 = (&tbl_E05B)[bVar2];
    (&DAT_024b)[bVar3] = cVar1;
    bVar3 = bVar3 + 1;
    bVar2 = bVar2 + 1;
  } while (cVar1 != -1);
  DAT_00d9 = 0;
  cVar1 = '\0';
  _DAT_0000 = 0x22f;
  _DAT_0002 = &DAT_001e;
  if ((DAT_0088 != '\x0f') && (DAT_00d2 != '\0')) goto bra_E046;
  do {
    if ((*(char *)(ushort)(byte)(cVar1 + 0xb8) == '\x04') &&
       ((DAT_0004 = *(char *)(ushort)(byte)(cVar1 + 0xb9) + 2U & 3,
        ((*_DAT_0002 | _DAT_0002[2]) & 7) != 0 ||
        ((*(byte *)(_DAT_0000 + (ushort)DAT_0004) & 0xf8) == 0)))) {
      *(byte *)(ushort)(byte)(cVar1 + 0xb9) = DAT_0004;
    }
bra_E046:
    _DAT_0000 = CONCAT11(DAT_0001,DAT_0000 + '\x04');
    _DAT_0002 = (byte *)CONCAT11(DAT_0003,DAT_0002 + '\x04');
    cVar1 = cVar1 + '\x02';
  } while (cVar1 != '\b');
  return;
}



/* ============================================================ */
/* sub_E003 @ e003 */
/* ============================================================ */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void sub_E003(void)

{
  char cVar1;
  
  cVar1 = '\0';
  _DAT_0000 = 0x22f;
  _DAT_0002 = &DAT_001e;
  if ((DAT_0088 != '\x0f') && (DAT_00d2 != '\0')) goto bra_E046;
  do {
    if ((*(char *)(ushort)(byte)(cVar1 + 0xb8) == '\x04') &&
       ((DAT_0004 = *(char *)(ushort)(byte)(cVar1 + 0xb9) + 2U & 3,
        ((*_DAT_0002 | _DAT_0002[2]) & 7) != 0 ||
        ((*(byte *)(_DAT_0000 + (ushort)DAT_0004) & 0xf8) == 0)))) {
      *(byte *)(ushort)(byte)(cVar1 + 0xb9) = DAT_0004;
    }
bra_E046:
    _DAT_0000 = CONCAT11(DAT_0001,DAT_0000 + '\x04');
    _DAT_0002 = (byte *)CONCAT11(DAT_0003,DAT_0002 + '\x04');
    cVar1 = cVar1 + '\x02';
  } while (cVar1 != '\b');
  return;
}



/* ============================================================ */
/* sub_E148 @ e148 */
/* ============================================================ */

char sub_E148(byte param_1)

{
  param_1 = param_1 & 0xf;
  if (param_1 < 10) {
    return param_1 + 0x30;
  }
  return param_1 + 0x37;
}



/* ============================================================ */
/* sub_E154_calculate_ppu_positions @ e154 */
/* ============================================================ */

void sub_E154_calculate_ppu_positions(void)

{
  char cVar1;
  byte bVar2;
  
  DAT_0002 = DAT_001a;
  DAT_0003 = DAT_001c;
  sub_E1DD_convert_position_to_ppu();
  DAT_0200 = DAT_0003;
  DAT_0201 = DAT_0002;
  cVar1 = '\0';
  bVar2 = 0;
  do {
    DAT_0002 = *(char *)(ushort)(byte)(cVar1 + 0x1a);
    DAT_0003 = *(undefined1 *)(ushort)(byte)(cVar1 + 0x1c);
    sub_E1DD_convert_position_to_ppu();
    DAT_0014 = 0x20;
    DAT_0015 = 0;
    DAT_0012 = DAT_0002;
    DAT_0013 = DAT_0003;
    sub_E24E_sbc_0020();
    *(undefined1 *)(bVar2 + 0x202) = DAT_0013;
    *(char *)((byte)(bVar2 + 1) + 0x202) = DAT_0012;
    *(undefined1 *)((byte)(bVar2 + 2) + 0x202) = DAT_0003;
    bVar2 = bVar2 + 3;
    *(char *)(bVar2 + 0x202) = DAT_0002 + -1;
    DAT_0014 = 0x20;
    DAT_0015 = 0;
    DAT_0012 = DAT_0002;
    DAT_0013 = DAT_0003;
    sub_E240_add_0020();
    *(undefined1 *)((byte)(bVar2 + 1) + 0x202) = DAT_0013;
    *(char *)((byte)(bVar2 + 2) + 0x202) = DAT_0012;
    *(undefined1 *)((byte)(bVar2 + 3) + 0x202) = DAT_0003;
    *(char *)((byte)(bVar2 + 4) + 0x202) = DAT_0002 + '\x01';
    cVar1 = cVar1 + '\x04';
    bVar2 = bVar2 + 5;
  } while (bVar2 != 0x28);
  return;
}



/* ============================================================ */
/* sub_E1DD_convert_position_to_ppu @ e1dd */
/* ============================================================ */

void sub_E1DD_convert_position_to_ppu(void)

{
  byte bVar1;
  byte bVar2;
  
  bVar2 = DAT_0003 - 4U & 0xf8;
  bVar1 = bVar2 * '\x04';
  DAT_0004 = bVar1 + 0x40;
  DAT_0005 = (((byte)(DAT_0003 - 4U) >> 7) << 1 | (byte)(bVar2 << 1) >> 7) + (0xbf < bVar1);
  DAT_0002 = ((byte)(DAT_0002 - 4U) >> 3) + DAT_0004;
  DAT_0003 = DAT_0005 + ' ';
  if ((DAT_0046 & DAT_0047) == 0) {
    return;
  }
  DAT_0003 = DAT_0005 + '(';
  return;
}



/* ============================================================ */
/* sub_E21C_analyze_obj_ppu_pos @ e21c */
/* ============================================================ */

void sub_E21C_analyze_obj_ppu_pos(void)

{
  char cVar1;
  byte bVar2;
  
  cVar1 = '\0';
  bVar2 = 0;
  do {
    DAT_2006 = *(undefined1 *)((byte)(cVar1 + 1) + 0x200);
    (&DAT_022a)[bVar2] = DAT_2007;
    cVar1 = cVar1 + '\x02';
    bVar2 = bVar2 + 1;
  } while (cVar1 != '*');
  return;
}



/* ============================================================ */
/* sub_E240_add_0020 @ e240 */
/* ============================================================ */

void sub_E240_add_0020(void)

{
  bool bVar1;
  
  bVar1 = CARRY1(DAT_0012,DAT_0014);
  DAT_0012 = DAT_0012 + DAT_0014;
  DAT_0013 = DAT_0013 + DAT_0015 + bVar1;
  return;
}



/* ============================================================ */
/* sub_E24E_sbc_0020 @ e24e */
/* ============================================================ */

void sub_E24E_sbc_0020(void)

{
  byte bVar1;
  byte bVar2;
  
  bVar2 = DAT_0012 - DAT_0014;
  bVar1 = ~DAT_0012;
  DAT_0012 = bVar2;
  DAT_0013 = (DAT_0013 - DAT_0015) - (((DAT_0014 & (bVar1 | bVar2) | bVar2 & bVar1) & 0x80) == 0);
  return;
}



/* ============================================================ */
/* sub_E25C @ e25c */
/* ============================================================ */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void sub_E25C(void)

{
  char cVar1;
  byte bVar2;
  bool bVar3;
  
  DAT_0002 = ' ';
  DAT_0003 = 0x40;
  if ((DAT_0047 & DAT_0046) != 0) {
    DAT_0002 = '(';
  }
  _DAT_0000 = CONCAT11(DAT_fff9,tbl_FFF8);
  cVar1 = '\x1b';
  bVar2 = 0;
  do {
    DAT_0004 = '\x16';
    do {
      DAT_0005 = (*(byte *)(_DAT_0000 + (ushort)bVar2) >> 7) << 1 |
                 (byte)(*(byte *)(_DAT_0000 + (ushort)bVar2) << 1) >> 7;
      do {
        DAT_0004 = DAT_0004 + -1;
        DAT_0005 = DAT_0005 - 1;
      } while (-1 < (char)DAT_0005);
      bVar2 = bVar2 + 1;
      if (bVar2 == 0) {
        _DAT_0000 = CONCAT11(DAT_0001 + '\x01',DAT_0000);
      }
    } while (DAT_0004 != '\0');
    bVar3 = 0xdf < DAT_0003;
    DAT_0003 = DAT_0003 + 0x20;
    DAT_0002 = DAT_0002 + bVar3;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  bVar2 = 2;
  DAT_0000 = '!';
  DAT_0001 = 0xd6;
  if ((DAT_0047 & DAT_0046) != 0) {
    DAT_0000 = ')';
    DAT_0001 = 0xd6;
  }
  do {
    cVar1 = '\a';
    DAT_2006 = DAT_0001;
    do {
      DAT_2007 = (&tbl_E2FC)[bVar2];
      cVar1 = cVar1 + -1;
    } while (-1 < cVar1);
    bVar3 = 0xdf < DAT_0001;
    DAT_0001 = DAT_0001 + 0x20;
    DAT_0000 = DAT_0000 + bVar3;
    bVar2 = bVar2 - 1;
  } while (-1 < (char)bVar2);
  return;
}



/* ============================================================ */
/* sub_E2FF @ e2ff */
/* ============================================================ */

/* WARNING: Removing unreachable block (RAM,0xe379) */
/* WARNING: Removing unreachable block (RAM,0xe38d) */
/* WARNING: Removing unreachable block (RAM,0xe393) */
/* WARNING: Removing unreachable block (RAM,0xe3a5) */
/* WARNING: Removing unreachable block (RAM,0xe3ab) */
/* WARNING: Removing unreachable block (RAM,0xe3b0) */
/* WARNING: Removing unreachable block (RAM,0xe3b4) */
/* WARNING: Removing unreachable block (RAM,0xe3e5) */
/* WARNING: Removing unreachable block (RAM,0xe3e9) */
/* WARNING: Removing unreachable block (RAM,0xe3ed) */

void sub_E2FF(void)

{
  char cVar1;
  
  DAT_0002 = '\x01';
  while( true ) {
    DAT_0003 = '\x01';
    DAT_0000 = '\x03';
    DAT_0001 = -0x40;
    while( true ) {
      do {
        do {
          DAT_0001 = DAT_0001 + -1;
        } while (DAT_0001 != '\0');
        DAT_0000 = DAT_0000 + -1;
      } while (-1 < DAT_0000);
      DAT_0003 = DAT_0003 + -1;
      if (DAT_0003 != '\0') break;
      DAT_0001 = '@';
      DAT_0003 = '\0';
    }
    DAT_0002 = DAT_0002 + -1;
    if (DAT_0002 != '\0') break;
    DAT_0002 = '\0';
  }
  DAT_0000 = '\x01';
  do {
    DAT_2006 = 0xc0;
    cVar1 = '\0';
    do {
      DAT_2007 = 0;
      cVar1 = cVar1 + '\x01';
    } while (cVar1 != ' ');
    DAT_0000 = DAT_0000 + -1;
  } while (DAT_0000 != '\0');
  return;
}



/* ============================================================ */
/* sub_E379 @ e379 */
/* ============================================================ */

/* WARNING: Removing unreachable block (RAM,0xe393) */

void sub_E379(void)

{
  byte bVar1;
  bool bVar2;
  
  DAT_0000 = ' ';
  DAT_0001 = 0xb6;
  DAT_0004 = 0x80;
  bVar1 = 0;
  if ((DAT_0047 & DAT_0046) != 0) {
    DAT_0000 = '(';
  }
  if ((DAT_0047 & DAT_0046) != 0) {
    bVar1 = 6;
  }
  DAT_0005 = '\x03';
  while( true ) {
    DAT_2006 = DAT_0001;
    DAT_0002 = (&tbl_E419_score_addr)[bVar1];
    DAT_0003 = *(undefined1 *)(bVar1 + 0xe41a);
    sub_E3EE();
    bVar1 = bVar1 + 2;
    bVar2 = CARRY1(DAT_0001,DAT_0004);
    DAT_0001 = DAT_0001 + DAT_0004;
    DAT_0000 = DAT_0000 + bVar2;
    DAT_0005 = DAT_0005 + -1;
    if ((DAT_0005 == '\x01') && (DAT_0047 == 0)) break;
    if (DAT_0005 == '\0') {
      return;
    }
  }
  return;
}



/* ============================================================ */
/* sub_E393 @ e393 */
/* ============================================================ */

void sub_E393(void)

{
  byte bVar1;
  bool bVar2;
  
  DAT_0000 = ' ';
  DAT_0001 = 0x83;
  DAT_0004 = 9;
  DAT_0047 = '\x01';
  bVar1 = 0xc;
  if ((DAT_0046 & 1) != 0) {
    bVar1 = 0x12;
  }
  DAT_0005 = '\x03';
  while( true ) {
    DAT_2006 = DAT_0001;
    DAT_0002 = (&tbl_E419_score_addr)[bVar1];
    DAT_0003 = *(undefined1 *)(bVar1 + 0xe41a);
    sub_E3EE();
    bVar1 = bVar1 + 2;
    bVar2 = CARRY1(DAT_0001,DAT_0004);
    DAT_0001 = DAT_0001 + DAT_0004;
    DAT_0000 = DAT_0000 + bVar2;
    DAT_0005 = DAT_0005 + -1;
    if ((DAT_0005 == '\x01') && (DAT_0047 == '\0')) break;
    if (DAT_0005 == '\0') {
      return;
    }
  }
  return;
}



/* ============================================================ */
/* sub_E3EE @ e3ee */
/* ============================================================ */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void sub_E3EE(void)

{
  byte bVar1;
  byte bVar2;
  
  bVar2 = 5;
  do {
    bVar1 = _DAT_0002[bVar2] & 0xf;
    if (bVar1 != 0) goto bra_E402;
    DAT_2007 = 0x20;
    bVar2 = bVar2 - 1;
  } while (bVar2 != 0);
bra_E40B:
  sub_E148(*_DAT_0002);
  DAT_2007 = 0x30;
  return;
bra_E402:
  while( true ) {
    DAT_2007 = sub_E148(bVar1);
    bVar2 = bVar2 - 1;
    if (bVar2 == 0) break;
    bVar1 = _DAT_0002[bVar2];
  }
  goto bra_E40B;
}



/* ============================================================ */
/* sub_E47C @ e47c */
/* ============================================================ */

void sub_E47C(void)

{
  bool bVar1;
  bool bVar2;
  char cVar3;
  byte bVar4;
  byte bVar5;
  
  bVar1 = true;
  do {
    cVar3 = '\0';
    do {
      DAT_2006 = (&tbl_E4B6)[(byte)(cVar3 + 1)];
      DAT_0000 = (&tbl_E4B6)[(byte)(cVar3 + 2U)];
      bVar4 = cVar3 + 2U;
      do {
        bVar5 = bVar4;
        bVar4 = bVar5 + 1;
        DAT_2007 = (&tbl_E4B6)[bVar4];
        DAT_0000 = DAT_0000 + -1;
      } while (DAT_0000 != '\0');
      cVar3 = bVar5 + 2;
      if ((cVar3 == '\x11') && (DAT_0047 == '\0')) {
        return;
      }
    } while (cVar3 != '\x17');
    bVar2 = !bVar1;
    bVar1 = false;
    if (bVar2) {
      return;
    }
  } while( true );
}



/* ============================================================ */
/* sub_E4CD @ e4cd */
/* ============================================================ */

void sub_E4CD(void)

{
  char cVar1;
  char cVar2;
  
  if (DAT_0067 == '\0') {
    return;
  }
  DAT_0002 = DAT_0067 + 1;
  if (6 < DAT_0002) {
    DAT_0002 = 7;
  }
  DAT_0003 = '\x04';
  DAT_0000 = 0x23;
  DAT_0001 = '\x17';
  if ((DAT_0046 & DAT_0047) != 0) {
    DAT_0000 = 0x2b;
  }
  do {
    DAT_0002 = DAT_0002 - 1;
    if (DAT_0002 == 0) {
      return;
    }
    DAT_0003 = DAT_0003 + -1;
    if (DAT_0003 == '\0') {
      DAT_0001 = DAT_0001 + ':';
    }
    cVar2 = '<';
    sub_E514();
    cVar1 = DAT_0001;
    DAT_0001 = DAT_0001 + '\x02';
  } while (DAT_0001 != '\0');
  DAT_2006 = cVar1 + '\"';
  DAT_2007 = cVar2 + '\x03';
  return;
}



/* ============================================================ */
/* sub_E514 @ e514 */
/* ============================================================ */

void sub_E514(char param_1)

{
  DAT_2006 = DAT_0001 + ' ';
  DAT_2007 = param_1 + '\x03';
  return;
}



/* ============================================================ */
/* sub_E53B @ e53b */
/* ============================================================ */

void sub_E53B(void)

{
  char cVar1;
  byte bVar2;
  byte bVar3;
  
  DAT_0003 = 0;
  DAT_000e = 0;
  DAT_000f = 0;
  DAT_000a = 0x15;
  DAT_000d = 0x11;
  DAT_000b = 5;
  DAT_000c = 5;
  DAT_0002 = DAT_0068;
  bVar2 = DAT_0068 - 7;
  if ((bVar2 & ~DAT_0068 & 0x80) == 0) {
    bVar2 = 0;
  }
  else {
    if (0xb < bVar2) {
      bVar2 = 0xc;
    }
    DAT_0002 = 7;
  }
  DAT_0000 = 0x22;
  DAT_0001 = 'V';
  if ((DAT_0046 & DAT_0047) != 0) {
    DAT_0000 = 0x2a;
  }
  DAT_0004 = '\x05';
  do {
    DAT_0004 = DAT_0004 + -1;
    if (DAT_0004 == '\0') {
      DAT_0001 = DAT_0001 + '8';
    }
    DAT_0005 = (&tbl_E619)[bVar2];
    sub_E514((DAT_0005 * '\x04' + '`') - ((char)(DAT_0005 << 1) >> 7));
    DAT_0006 = (&tbl_E62D)[DAT_0003];
    DAT_0007 = (&DAT_e62e)[DAT_0003];
    bVar3 = (&tbl_E63D)[DAT_0005];
    do {
      DAT_0007 = DAT_0007 + -1;
      if (DAT_0007 < '\0') break;
      cVar1 = bVar3 << 1;
      bVar3 = bVar3 << 2;
    } while (-1 < cVar1);
    *(byte *)(DAT_0006 + 10) = bVar3 | *(byte *)(DAT_0006 + 10);
    DAT_0001 = DAT_0001 + '\x02';
    DAT_0003 = DAT_0003 + 2;
    bVar2 = bVar2 + 1;
    DAT_0002 = DAT_0002 - 1;
    if ((char)DAT_0002 < '\0') {
      DAT_0000 = 0x23;
      if ((DAT_0047 & DAT_0046) != 0) {
        DAT_0000 = 0x2b;
      }
      while( true ) {
        DAT_0001 = '\x03';
        do {
          DAT_0001 = DAT_0001 + -1;
        } while (DAT_0001 != '\0');
        DAT_0002 = DAT_0002 + 1;
        if (DAT_0002 != '\0') break;
        DAT_0002 = 0;
      }
      DAT_2006 = 0x1d;
      bVar2 = DAT_0068;
      if (0xf < DAT_0068) {
        bVar2 = 0xf;
      }
      DAT_2007 = (&tbl_E645_fruit_color)[bVar2];
      return;
    }
  } while( true );
}



/* ============================================================ */
/* sub_E6C4 @ e6c4 */
/* ============================================================ */

void sub_E6C4(void)

{
  char cVar1;
  
  DAT_2006 = 0;
  DAT_0000 = '\x1c';
  do {
    DAT_0001 = '\x02';
    DAT_0002 = '\x1c';
    DAT_0003 = '\x02';
    do {
      while( true ) {
        for (; DAT_0001 != '\0'; DAT_0001 = DAT_0001 + -1) {
        }
        if (DAT_0002 == '\0') break;
        DAT_0002 = DAT_0002 + -1;
      }
      DAT_0003 = DAT_0003 + -1;
    } while (DAT_0003 != '\0');
    DAT_0000 = DAT_0000 + -1;
  } while (DAT_0000 != '\0');
  cVar1 = '\0';
  do {
    DAT_2007 = 0;
    cVar1 = cVar1 + '\x01';
  } while (cVar1 != '@');
  if (DAT_0087 == '\x02') {
    DAT_2006 = 0x30;
    DAT_2007 = 0x5e;
    return;
  }
  return;
}



/* ============================================================ */
/* sub_E75A @ e75a */
/* ============================================================ */

void sub_E75A(void)

{
  DAT_0010 = (code *)CONCAT11(*(undefined1 *)(DAT_0087 + 0xe76a),(&tbl_E769)[DAT_0087]);
                    /* WARNING: Could not recover jumptable at 0xe766. Too many branches */
                    /* WARNING: Treating indirect jump as call */
  (*DAT_0010)();
  return;
}



/* ============================================================ */
/* sub_E9A5 @ e9a5 */
/* ============================================================ */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void sub_E9A5(void)

{
  byte bVar1;
  byte bVar2;
  byte bVar3;
  
  _DAT_0000 = &DAT_001a;
  _DAT_0002 = &DAT_0274;
  bVar3 = 0;
  do {
    if (*_DAT_0002 != 0) {
      bVar2 = _DAT_0000[1];
      bVar1 = _DAT_0002[1];
      _DAT_0002[1] = bVar2 + bVar1;
      bVar2 = *_DAT_0000 + *_DAT_0002 + CARRY1(bVar2,bVar1);
      *_DAT_0002 = bVar2;
      if (bVar2 < 0xc0) goto bra_E9DA;
      do {
        bVar1 = (&DAT_0292)[bVar3];
        (&DAT_0292)[bVar3] = bVar1 | 0x20;
        bVar2 = 0;
        if ((bVar1 | 0x20) != 0) goto bra_E9E6;
bra_E9DA:
      } while (bVar2 < 0x40);
      (&DAT_0292)[bVar3] = (&DAT_0292)[bVar3] & 0xdf;
bra_E9E6:
      if ((0xfb < *_DAT_0002) || (*_DAT_0002 < 4)) {
        *_DAT_0002 = 0;
        *_DAT_0000 = '\0';
        _DAT_0000[1] = '\0';
        _DAT_0002[2] = 0;
      }
    }
    _DAT_0000 = (char *)CONCAT11(DAT_0001 + (0xfb < DAT_0000),DAT_0000 + 4);
    _DAT_0002 = (byte *)CONCAT11(DAT_0003 + (0xfb < DAT_0002),DAT_0002 + 4);
    bVar3 = bVar3 + 1;
    if (bVar3 == 5) {
      return;
    }
  } while( true );
}



/* ============================================================ */
/* sub_EA20 @ ea20 */
/* ============================================================ */

void sub_EA20(void)

{
  DAT_0010 = (code *)CONCAT11(*(undefined1 *)(DAT_0087 + 0xea30),(&tbl_EA2F)[DAT_0087]);
                    /* WARNING: Could not recover jumptable at 0xea2c. Too many branches */
                    /* WARNING: Treating indirect jump as call */
  (*DAT_0010)();
  return;
}



/* ============================================================ */
/* ofs_017_EA62_02 @ ea62 */
/* ============================================================ */

/* WARNING: Removing unreachable block (RAM,0xea79) */
/* WARNING: Removing unreachable block (RAM,0xea7f) */
/* WARNING: Removing unreachable block (RAM,0xea80) */
/* WARNING: Removing unreachable block (RAM,0xea8a) */
/* WARNING: Removing unreachable block (RAM,0xea86) */
/* WARNING: Removing unreachable block (RAM,0xea8c) */

void ofs_017_EA62_02(void)

{
  if ((DAT_004b & 7) == 0) {
    if ((DAT_004b & 8) == 0) {
      DAT_028c = 0xc;
    }
    else {
      DAT_028c = 0xd;
    }
  }
  DAT_00b7 = DAT_00b7 + 1;
  DAT_028d = (&tbl_EA5A)[DAT_00b7 & 7];
  return;
}



/* ============================================================ */
/* sub_EE18 @ ee18 */
/* ============================================================ */

void sub_EE18(void)

{
  char cVar1;
  byte bVar2;
  
  DAT_00f0 = 0x600;
  DAT_00f2 = 0x620;
  DAT_00f4._0_1_ = tbl_F08C;
  DAT_00f4._1_1_ = DAT_f08d;
  DAT_00f7 = 0x40;
  DAT_4015 = 0x1f;
  DAT_4017 = 0xc0;
  bVar2 = 0;
  do {
    *(undefined1 *)(DAT_00f0 + (ushort)bVar2) = 0;
    bVar2 = bVar2 + 1;
  } while (bVar2 != 0x10);
  bVar2 = 0;
  cVar1 = '\x10';
  do {
    *(undefined1 *)(DAT_00f2 + (ushort)bVar2) = 0;
    bVar2 = bVar2 + 8;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}



/* ============================================================ */
/* sub_EE40 @ ee40 */
/* ============================================================ */

void sub_EE40(void)

{
  char cVar1;
  byte bVar2;
  
  bVar2 = 0;
  do {
    *(undefined1 *)(DAT_00f0 + (ushort)bVar2) = 0;
    bVar2 = bVar2 + 1;
  } while (bVar2 != 0x10);
  bVar2 = 0;
  cVar1 = '\x10';
  do {
    *(undefined1 *)(DAT_00f2 + (ushort)bVar2) = 0;
    bVar2 = bVar2 + 8;
    cVar1 = cVar1 + -1;
  } while (cVar1 != '\0');
  return;
}



/* ============================================================ */
/* sub_EE5C_update_sound_engine @ ee5c */
/* ============================================================ */
/* Low-level Error: Overlapping input varnodes */

/* ============================================================ */
/* sub_F04F_get_sound_data_and_increase_pointer @ f04f */
/* ============================================================ */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

undefined1 sub_F04F_get_sound_data_and_increase_pointer(void)

{
  undefined1 uVar1;
  byte bVar2;
  byte bVar3;
  
  bVar2 = *(byte *)(DAT_00f2 + (ushort)(byte)(DAT_00fd + 5));
  bVar3 = DAT_00fd + 6;
  _DAT_00fe = (undefined1 *)CONCAT11(*(undefined1 *)(DAT_00f2 + (ushort)bVar3),bVar2);
  uVar1 = *_DAT_00fe;
  *(byte *)(DAT_00f2 + (ushort)(byte)(DAT_00fd + 5)) = bVar2 + 1;
  *(char *)(DAT_00f2 + (ushort)bVar3) = DAT_00ff + (0xfe < bVar2);
  return uVar1;
}



