package com.ruoyi.web.controller.system;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.commons.lang3.ArrayUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.entity.SysDept;
import com.ruoyi.common.core.domain.entity.SysRole;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.entity.SysUserPointAccount;
import com.ruoyi.common.core.domain.entity.SysUserWallet;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.system.service.ISysDeptService;
import com.ruoyi.system.service.ISysPostService;
import com.ruoyi.system.service.ISysRoleService;
import com.ruoyi.system.service.ISysUserPointService;
import com.ruoyi.system.service.ISysUserService;
import com.ruoyi.system.service.ISysUserWalletService;
import com.ruoyi.framework.security.crypto.ApiCryptoService;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

/**
 * 用户信息管理。
 *
 * 后台用户列表、详情、编辑、删除等操作统一通过用户服务访问，读取侧会命中缓存。
 * 
 * @author ruoyi
 */
@RestController
@RequestMapping("/system/user")
public class SysUserController extends BaseController
{
    private static final Logger log = LoggerFactory.getLogger(SysUserController.class);

    @Autowired
    private ISysUserService userService;

    @Autowired
    private ISysRoleService roleService;

    @Autowired
    private ISysDeptService deptService;

    @Autowired
    private ISysPostService postService;

    @Autowired
    private ISysUserWalletService walletService;

    @Autowired
    private ISysUserPointService pointService;

    @Autowired
    private ApiCryptoService apiCryptoService;

    @Autowired
    private ObjectMapper objectMapper;

    /**
     * 获取用户列表。
     */
    @PreAuthorize("@ss.hasPermi('system:user:list')")
    @GetMapping("/list")
    public TableDataInfo list(SysUser user)
    {
        startPage();
        List<SysUser> list = userService.selectUserList(user);
        return getDataTable(list);
    }

    @Log(title = "鐢ㄦ埛绠＄悊", businessType = BusinessType.EXPORT)
    @PreAuthorize("@ss.hasPermi('system:user:export')")
    @PostMapping("/export")
    public void export(HttpServletResponse response, SysUser user)
    {
        List<SysUser> list = userService.selectUserList(user);
        ExcelUtil<SysUser> util = new ExcelUtil<SysUser>(SysUser.class);
        util.exportExcel(response, list, "鐢ㄦ埛鏁版嵁");
    }

    @Log(title = "鐢ㄦ埛绠＄悊", businessType = BusinessType.IMPORT)
    @PreAuthorize("@ss.hasPermi('system:user:import')")
    @PostMapping("/importData")
    public AjaxResult importData(MultipartFile file, boolean updateSupport) throws Exception
    {
        ExcelUtil<SysUser> util = new ExcelUtil<SysUser>(SysUser.class);
        List<SysUser> userList = util.importExcel(file.getInputStream());
        String operName = getUsername();
        String message = userService.importUser(userList, updateSupport, operName);
        return success(message);
    }

    @PostMapping("/importTemplate")
    public void importTemplate(HttpServletResponse response)
    {
        ExcelUtil<SysUser> util = new ExcelUtil<SysUser>(SysUser.class);
        util.importTemplateExcel(response, "鐢ㄦ埛鏁版嵁");
    }

    /**
     * 根据用户编号获取详细信息。
     */
    @PreAuthorize("@ss.hasPermi('system:user:query')")
    @GetMapping(value = { "/", "/{userId}" })
    public AjaxResult getInfo(@PathVariable(value = "userId", required = false) Long userId)
    {
        AjaxResult ajax = AjaxResult.success();
        if (StringUtils.isNotNull(userId))
        {
            userService.checkUserDataScope(userId);
            SysUser sysUser = userService.selectUserById(userId);
            ajax.put(AjaxResult.DATA_TAG, sysUser);
            ajax.put("postIds", postService.selectPostListByUserId(userId));
            ajax.put("roleIds", sysUser.getRoles().stream().map(SysRole::getRoleId).collect(Collectors.toList()));
        }
        List<SysRole> roles = roleService.selectRoleAll();
        ajax.put("roles", SecurityUtils.isAdmin(userId) ? roles : roles.stream().filter(r -> !r.isAdmin()).collect(Collectors.toList()));
        ajax.put("posts", postService.selectPostAll());
        return ajax;
    }

    /**
     * 新增用户。
     */
    @PreAuthorize("@ss.hasPermi('system:user:add')")
    @Log(title = "鐢ㄦ埛绠＄悊", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody SysUser user)
    {
        deptService.checkDeptDataScope(user.getDeptId());
        roleService.checkRoleDataScope(user.getRoleIds());
        if (!userService.checkUserNameUnique(user))
        {
            return error("鏂板鐢ㄦ埛'" + user.getUserName() + "'澶辫触锛岀櫥褰曡处鍙峰凡瀛樺湪");
        }
        else if (StringUtils.isNotEmpty(user.getPhonenumber()) && !userService.checkPhoneUnique(user))
        {
            return error("鏂板鐢ㄦ埛'" + user.getUserName() + "'澶辫触锛屾墜鏈哄彿鐮佸凡瀛樺湪");
        }
        else if (StringUtils.isNotEmpty(user.getEmail()) && !userService.checkEmailUnique(user))
        {
            return error("鏂板鐢ㄦ埛'" + user.getUserName() + "'澶辫触锛岄偖绠辫处鍙峰凡瀛樺湪");
        }
        user.setCreateBy(getUsername());
        user.setPassword(SecurityUtils.encryptPassword(user.getPassword()));
        int rows = userService.insertUser(user);
        if (rows > 0)
        {
            ensureDefaultWallets(user.getUserId());
            ensureDefaultPointAccount(user.getUserId(), user.getUserName());
        }
        return toAjax(rows);
    }

    /**
     * 修改用户。
     */
    @PreAuthorize("@ss.hasPermi('system:user:edit')")
    @Log(title = "鐢ㄦ埛绠＄悊", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody SysUser user)
    {
        userService.checkUserAllowed(user);
        userService.checkUserDataScope(user.getUserId());
        deptService.checkDeptDataScope(user.getDeptId());
        roleService.checkRoleDataScope(user.getRoleIds());
        if (!userService.checkUserNameUnique(user))
        {
            return error("淇敼鐢ㄦ埛'" + user.getUserName() + "'澶辫触锛岀櫥褰曡处鍙峰凡瀛樺湪");
        }
        else if (StringUtils.isNotEmpty(user.getPhonenumber()) && !userService.checkPhoneUnique(user))
        {
            return error("淇敼鐢ㄦ埛'" + user.getUserName() + "'澶辫触锛屾墜鏈哄彿鐮佸凡瀛樺湪");
        }
        else if (StringUtils.isNotEmpty(user.getEmail()) && !userService.checkEmailUnique(user))
        {
            return error("淇敼鐢ㄦ埛'" + user.getUserName() + "'澶辫触锛岄偖绠辫处鍙峰凡瀛樺湪");
        }
        user.setUpdateBy(getUsername());
        return toAjax(userService.updateUser(user));
    }

    /**
     * 删除用户。
     */
    @PreAuthorize("@ss.hasPermi('system:user:remove')")
    @Log(title = "鐢ㄦ埛绠＄悊", businessType = BusinessType.DELETE)
    @DeleteMapping("/{userIds}")
    public AjaxResult remove(@PathVariable Long[] userIds)
    {
        if (ArrayUtils.contains(userIds, getUserId()))
        {
            return error("褰撳墠鐢ㄦ埛涓嶈兘鍒犻櫎");
        }
        return toAjax(userService.deleteUserByIds(userIds));
    }

    /**
     * 重置密码。
     */
    @PreAuthorize("@ss.hasPermi('system:user:resetPwd')")
    @Log(title = "鐢ㄦ埛绠＄悊", businessType = BusinessType.UPDATE)
    @PutMapping("/resetPwd")
    public AjaxResult resetPwd(@RequestBody SysUser user)
    {
        userService.checkUserAllowed(user);
        userService.checkUserDataScope(user.getUserId());
        user.setPassword(SecurityUtils.encryptPassword(user.getPassword()));
        user.setUpdateBy(getUsername());
        return toAjax(userService.resetPwd(user));
    }

    /**
     * 修改状态。
     */
    @PreAuthorize("@ss.hasPermi('system:user:edit')")
    @Log(title = "鐢ㄦ埛绠＄悊", businessType = BusinessType.UPDATE)
    @PutMapping("/changeStatus")
    public AjaxResult changeStatus(@RequestBody SysUser user)
    {
        userService.checkUserAllowed(user);
        userService.checkUserDataScope(user.getUserId());
        user.setUpdateBy(getUsername());
        return toAjax(userService.updateUserStatus(user));
    }

    /**
     * 根据用户编号获取授权角色。
     */
    @PreAuthorize("@ss.hasPermi('system:user:query')")
    @GetMapping("/authRole/{userId}")
    public AjaxResult authRole(@PathVariable("userId") Long userId)
    {
        AjaxResult ajax = AjaxResult.success();
        SysUser user = userService.selectUserById(userId);
        List<SysRole> roles = roleService.selectRolesByUserId(userId);
        ajax.put("user", user);
        ajax.put("roles", SecurityUtils.isAdmin(userId) ? roles : roles.stream().filter(r -> !r.isAdmin()).collect(Collectors.toList()));
        return ajax;
    }

    /**
     * 鐢ㄦ埛鎺堟潈瑙掕壊
     */
    @PreAuthorize("@ss.hasPermi('system:user:edit')")
    @Log(title = "鐢ㄦ埛绠＄悊", businessType = BusinessType.GRANT)
    @PutMapping("/authRole")
    public AjaxResult insertAuthRole(Long userId, Long[] roleIds)
    {
        userService.checkUserDataScope(userId);
        roleService.checkRoleDataScope(roleIds);
        userService.insertUserAuth(userId, roleIds);
        return success();
    }

    /**
     * 鑾峰彇閮ㄩ棬鏍戝垪琛?
     */
    @PreAuthorize("@ss.hasPermi('system:user:list')")
    @GetMapping("/deptTree")
    public AjaxResult deptTree(SysDept dept)
    {
        return success(deptService.selectDeptTreeList(dept));
    }

    /**
     * 璁剧疆鏀粯瀵嗙爜
     */
    @PutMapping("/setPayPwd")
    public AjaxResult setPayPwd(@RequestBody(required = false) Map<String, Object> params)
    {
        log.info("setPayPwd params={}", params);
        Long currentUserId = getUserId();
        Long userId = currentUserId;
        if (params != null && params.get("userId") != null)
        {
            try
            {
                userId = Long.valueOf(params.get("userId").toString());
            }
            catch (Exception ignored)
            {
                userId = currentUserId;
            }
        }
        if (!userId.equals(currentUserId))
        {
            userService.checkUserDataScope(userId);
        }

        String payPassword = null;
        if (params != null)
        {
            payPassword = params.get("payPassword") != null ? params.get("payPassword").toString() : null;
            if (StringUtils.isBlank(payPassword) && params.get("password") != null)
            {
                payPassword = params.get("password").toString();
            }
            if (StringUtils.isBlank(payPassword) && params.get("data") != null)
            {
                try
                {
                    String cipherText = params.get("data").toString();
                    String plainJson = apiCryptoService.decryptText(cipherText);
                    Map<String, Object> decryptedParams = objectMapper.readValue(
                            plainJson, new TypeReference<Map<String, Object>>() {});
                    log.info("setPayPwd decrypted params={}", decryptedParams);
                    if (decryptedParams != null)
                    {
                        if (decryptedParams.get("userId") != null)
                        {
                            try
                            {
                                userId = Long.valueOf(decryptedParams.get("userId").toString());
                            }
                            catch (Exception ignored)
                            {
                                userId = currentUserId;
                            }
                        }
                        if (decryptedParams.get("payPassword") != null)
                        {
                            payPassword = decryptedParams.get("payPassword").toString();
                        }
                        if (StringUtils.isBlank(payPassword) && decryptedParams.get("password") != null)
                        {
                            payPassword = decryptedParams.get("password").toString();
                        }
                    }
                }
                catch (Exception ex)
                {
                    log.warn("setPayPwd fallback decrypt failed, paramsKeys={}", params.keySet(), ex);
                }
            }
        }
        if (StringUtils.isBlank(payPassword))
        {
            return error("支付密码不能为空");
        }
        if (payPassword.length() < 6)
        {
            return error("支付密码长度不能少于6位");
        }
        if (!payPassword.matches("^\\d+$"))
        {
            return error("支付密码必须为数字");
        }

        SysUser user = userService.selectUserById(userId);
        if (user == null)
        {
            return error("用户不存在");
        }
        userService.checkUserAllowed(user);
        user.setPayPassword(SecurityUtils.encryptPassword(payPassword));
        user.setUpdateBy(getUsername());
        return toAjax(userService.updateUser(user));
    }

    /**
     * 淇敼鏀粯瀵嗙爜
     */
    @PutMapping("/updatePayPwd")
    public AjaxResult updatePayPwd(@RequestBody Map<String, Object> params)
    {
        Long userId = params.get("userId") != null ? Long.valueOf(params.get("userId").toString()) : getUserId();
        String oldPayPwd = params.get("oldPayPwd") != null ? params.get("oldPayPwd").toString() : null;
        if (StringUtils.isBlank(oldPayPwd) && params.get("oldPassword") != null)
        {
            oldPayPwd = params.get("oldPassword").toString();
        }
        String newPayPwd = params.get("newPayPwd") != null ? params.get("newPayPwd").toString() : null;
        if (StringUtils.isBlank(newPayPwd) && params.get("newPassword") != null)
        {
            newPayPwd = params.get("newPassword").toString();
        }

        if (!userId.equals(getUserId()))
        {
            userService.checkUserDataScope(userId);
        }

        if (StringUtils.isBlank(oldPayPwd))
        {
            return error("旧支付密码不能为空");
        }
        if (!oldPayPwd.matches("^\\d+$"))
        {
            return error("旧支付密码必须为数字");
        }

        if (StringUtils.isBlank(newPayPwd))
        {
            return error("新支付密码不能为空");
        }
        if (newPayPwd.length() < 6)
        {
            return error("新支付密码长度不能少于6位");
        }
        if (!newPayPwd.matches("^\\d+$"))
        {
            return error("新支付密码必须为数字");
        }

        SysUser currentUser = userService.selectUserById(userId);
        if (!SecurityUtils.matchesPassword(oldPayPwd, currentUser.getPayPassword()))
        {
            return error("旧支付密码错误");
        }

        if (SecurityUtils.matchesPassword(newPayPwd, currentUser.getPayPassword()))
        {
            return error("新支付密码不能与旧密码相同");
        }

        SysUser user = new SysUser();
        user.setUserId(userId);
        user.setPayPassword(SecurityUtils.encryptPassword(newPayPwd));
        user.setUpdateBy(getUsername());
        return toAjax(userService.updateUser(user));
    }

    /**
     * 验证支付密码
     */
    @PostMapping("/verifyPayPwd")
    public AjaxResult verifyPayPwd(@RequestParam(required = false) Long userId,
                                   @RequestParam(required = false) String payPwd,
                                   @RequestParam(required = false) String password)
    {
        if (userId == null)
        {
            userId = getUserId();
        }
        if (!userId.equals(getUserId()))
        {
            userService.checkUserDataScope(userId);
        }

        if (StringUtils.isBlank(payPwd) && StringUtils.isNotBlank(password))
        {
            payPwd = password;
        }

        SysUser user = userService.selectUserById(userId);
        if (StringUtils.isBlank(user.getPayPassword()))
        {
            return error("支付密码未设置");
        }

        if (!SecurityUtils.matchesPassword(payPwd, user.getPayPassword()))
        {
            return error("支付密码错误");
        }

        return success();
    }

    /**
     * 检查支付密码是否设置
     */
    @GetMapping("/checkPayPwdSet/{userId}")
    public AjaxResult checkPayPwdSet(@PathVariable Long userId)
    {
        if (!userId.equals(getUserId()))
        {
            userService.checkUserDataScope(userId);
        }

        SysUser user = userService.selectUserById(userId);
        boolean isSet = StringUtils.isNotBlank(user.getPayPassword());
        return success(isSet);
    }

    private void ensureDefaultWallets(Long userId)
    {
        if (userId == null)
        {
            return;
        }
        createWalletIfAbsent(userId, "CNY");
        createWalletIfAbsent(userId, "USD");
    }

    private void createWalletIfAbsent(Long userId, String currencyType)
    {
        SysUserWallet wallet = walletService.selectWalletByUserIdAndCurrencyType(userId, currencyType);
        if (wallet != null)
        {
            return;
        }
        SysUserWallet newWallet = new SysUserWallet();
        newWallet.setUserId(userId);
        newWallet.setCurrencyType(currencyType);
        newWallet.setTotalInvest(0D);
        newWallet.setAvailableBalance(0D);
        newWallet.setUsdExchangeQuota(0D);
        newWallet.setFrozenAmount(0D);
        newWallet.setProfitAmount(0D);
        newWallet.setPendingAmount(0D);
        newWallet.setTotalRecharge(0D);
        newWallet.setTotalWithdraw(0D);
        walletService.insertWallet(newWallet);
    }

    private void ensureDefaultPointAccount(Long userId, String userName)
    {
        if (userId == null)
        {
            return;
        }
        SysUserPointAccount pointAccount = pointService.selectPointAccountByUserId(userId);
        if (pointAccount != null)
        {
            return;
        }
        SysUserPointAccount newPointAccount = new SysUserPointAccount();
        newPointAccount.setUserId(userId);
        newPointAccount.setUserName(userName);
        newPointAccount.setAvailablePoints(0L);
        newPointAccount.setFrozenPoints(0L);
        newPointAccount.setTotalEarned(0L);
        newPointAccount.setTotalSpent(0L);
        newPointAccount.setTotalAdjusted(0L);
        pointService.insertPointAccount(newPointAccount);
    }
}

